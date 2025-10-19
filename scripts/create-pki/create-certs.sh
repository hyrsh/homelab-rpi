#!/bin/bash

tpl_dir=./templates #openssl v3 template dir
ts=$(date +%Y%m%d-%H%M%S) #current timestamp for directory creation
domain="my-testdomain.pub.io" #fail-safe for unknown errors or hacks
root_ca_expiry=10000 #days for your root ca to expire
int_ca_expiry=8000  #days for your intermediate ca to expire

# Generic fail-safe and usage example
# Set first parameter as domain variable

if [ "$1" == "" ]; then
  echo -e "\e[31;1m[!] No domain given!\e[0;0m"
  echo -e "\e[36;1m---"
  echo -e "[+] Usage:"
  echo -e "- e.g. ./create-certs.sh myserver.mydomain.io"
  echo -e "- e.g. ./create-certs.sh coolserver.homelab.org"
  echo -e "---\e[0;0m"
  exit 1
else
  domain=$1
fi

# Split domain

d_srv=$(echo $domain | awk -F\. '{print $1}')
d_dom=$(echo $domain | awk -F\. '{print $2}')
d_apx=$(echo $domain | awk -F\. '{print $3}')

# Simple check for 3x parts with dots as separator

if [ "$d_srv" == "" ] || [ "$d_dom" == "" ] || [ "$d_apx" == "" ] || [ "$(echo $domain | awk -F\. '{print $NF}')" != "$d_apx" ]; then
  echo -e "\e[31;1m[!] Given domain is not in correct format (e.g. myserver.domain.io)\e[0;0m"
  exit 2
fi

# Create output dir for certificates

output_dir="cert_$(echo $domain | sed "s/\./_/g")_${ts}"

echo -e "\e[32;1mUsing dir: $output_dir\e[0;0m"

# Creating OpenSSL settings
mkdir -p ./$output_dir/additional_info

cp $tpl_dir/root_ca_v3.cnf.tpl ./$output_dir/additional_info/root_ca_v3.cnf
sed -i "s/{{ output_dir }}/$output_dir/g" ./$output_dir/additional_info/root_ca_v3.cnf #set output dir

cp $tpl_dir/int_ca_v3.cnf.tpl ./$output_dir/additional_info/int_ca_v3.cnf
sed -i "s/{{ output_dir }}/$output_dir/g" ./$output_dir/additional_info/int_ca_v3.cnf #set output dir
sed -i "s/{{ domain }}/$domain/g" ./$output_dir/additional_info/int_ca_v3.cnf #set domain for automated request processing

echo "2000" > ./$output_dir/additional_info/serial_root
echo "2000" > ./$output_dir/additional_info/serial_intermediate
echo "0100" > ./$output_dir/additional_info/crlnumber_root
echo "0100" > ./$output_dir/additional_info/crlnumber_intermediate
touch ./$output_dir/additional_info/index_root.txt
touch ./$output_dir/additional_info/index_intermediate.txt

# Create root CA key
openssl genrsa -out ./$output_dir/root_ca.key.pem 4096
# Create root CA cert
openssl req -config ./$output_dir/additional_info/root_ca_v3.cnf -key ./$output_dir/root_ca.key.pem -new -x509 -days $root_ca_expiry -sha256 -extensions v3_ca -out ./$output_dir/root_ca.cert.pem -subj "/C=CH/ST=Zug/L=Zug/O=TLSCorp/OU=Self-Signed PKI/CN=Root CA"

# Create int CA key
openssl genrsa -out ./$output_dir/intermediate_ca.key.pem 4096
# Create int CA CSR
openssl req -config ./$output_dir/additional_info/int_ca_v3.cnf -key ./$output_dir/intermediate.key.pem -new -sha256 -out ./$output_dir/intermediate.csr.pem -subj "/C=CH/ST=Zug/L=Zug/O=TLSCorp/OU=Self-Signed PKI/CN=Intermediate CA"
# Sign CSR with root CA
openssl ca -config ./$output_dir/additional_info/root_ca_v3.cnf -extensions v3_intermediate_ca -days $int_ca_expiry -notext -md sha256 -in ./$output_dir/intermediate.csr.pem -out ./$output_dir/intermediate.cert.pem












