#!/bin/bash

# General variables
tpl_dir=./templates #openssl v3 template dir
ts=$(date +%Y%m%d-%H%M%S) #current timestamp for directory creation
domain="my-testdomain.pub.io" #fail-safe for unknown errors or hacks

# Set expiry in days and subject information defaults
root_ca_expiry=10000 #days for your root ca to expire
int_ca_expiry=8000  #days for your intermediate ca to expire
srv_cert_expiry=5000 #day for your server certificate to expire
sub_country="CH"
sub_state="Zug"
sub_location="Zug"
sub_org="TLSCorp"
sub_ou="Self-signed PKI"

# Explanation of flags
help () {
  echo -e "\e[36;1m"
  echo -e "[+] Usage:"
  echo -e "----------"
  echo -e "- e.g. ./create-certs.sh -domain *.homelab.org -s-exp 1000 -r-exp 10000 -i-exp 8000"
  echo -e ""
  echo -e "[+] Flags:"
  echo -e "----------"
  echo -e "  -r-exp|-root-expiry         > days of expiration of your root CA"
  echo -e "  -i-exp|-intermediate-expiry > days of expiration of your intermediate CA"
  echo -e "  -s-exp|-server-expiry       > days of expiration of your server cert"
  echo -e "  -d|-domain                  > domain of your server cert"
  echo -e "  -c|-country                 > country of your INT/ROOT CA"
  echo -e "  -st|-state                  > state of your INT/ROOT CA"
  echo -e "  -l|-location                > location of your INT/ROOT CA"
  echo -e "  -org|-organization          > organization of your INT/ROOT CA"
  echo -e "  -ou|-organizational-unit    > organizational unit of your INT/ROOT CA"
  echo -e "  -h|-help                    > prints this help"
  echo -e "\e[0;0m"
  exit 0
}

# Go through args to allow customization
while [ $# -gt 0 ]; do

  case $1 in
    -r-exp|-root-expiry)
      shift
      root_ca_expiry=$1
      shift
      ;;
    -i-exp|-intermediate-expiry)
      shift
      int_ca_expiry=$1
      shift
      ;;
    -s-exp|-server-expiry)
      shift
      srv_cert_expiry=$1
      shift
      ;;
    -dom|-domain)
      shift
      domain=$1
      shift
      ;;
    -c|-country)
      shift
      sub_country=$1
      shift
      ;;
    -st|-state)
      shift
      sub_state=$1
      shift
      ;;
    -l|-location)
      shift
      sub_location=$1
      shift
      ;;
    -org|-organization)
      shift
      sub_org=$1
      shift
      ;;
    -ou|-organizational-unit)
      shift
      sub_ou=$1
      shift
      ;;
    -h|-help)
      help
      ;;
    *)
      echo -n "$1 "
      shift
      echo "$1 not found!"
      shift
      ;;
  esac

done

# Build subjects
root_subject="/C=$sub_country/ST=$sub_state/L=$sub_location/O=$sub_org/OU=$sub_ou/CN=Root CA"
int_subject="/C=$sub_country/ST=$sub_state/L=$sub_location/O=$sub_org/OU=$sub_ou/CN=Intermediate CA"

# Split domain
d_srv=$(echo $domain | awk -F\. '{print $1}')
d_dom=$(echo $domain | awk -F\. '{print $2}')
d_apx=$(echo $domain | awk -F\. '{print $3}')

# Simple check for 3x parts with dots as separator
if [ "$d_srv" == "" ] || [ "$d_dom" == "" ] || [ "$d_apx" == "" ] || [ "$(echo $domain | awk -F\. '{print $NF}')" != "$d_apx" ]; then
  echo -e "\e[31;1m[!] Given domain is not in correct format (e.g. myserver.domain.io)\e[0;0m"
  exit 1
fi
echo -e "\e[32;1m[+] Using domain: $domain\e[0;0m"

# Create output dir for certificates
output_dir="cert_$(echo $domain | sed "s/\./_/g")_${ts}"
echo -e "\e[32;1m[+] Using dir: $output_dir\e[0;0m"

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
openssl req -config ./$output_dir/additional_info/root_ca_v3.cnf -key ./$output_dir/root_ca.key.pem -new -x509 -days $root_ca_expiry -sha256 -extensions v3_ca -out ./$output_dir/root_ca.cert.pem -subj "$root_subject"

# Create int CA key
openssl genrsa -out ./$output_dir/intermediate_ca.key.pem 4096
# Create int CA CSR
openssl req -config ./$output_dir/additional_info/int_ca_v3.cnf -key ./$output_dir/intermediate_ca.key.pem -new -sha256 -out ./$output_dir/intermediate_ca.csr.pem -subj "$int_subject"
# Sign CSR with root CA
openssl ca -config ./$output_dir/additional_info/root_ca_v3.cnf -extensions v3_intermediate_ca -days $int_ca_expiry -notext -md sha256 -in ./$output_dir/intermediate_ca.csr.pem -out ./$output_dir/intermediate_ca.cert.pem
# Move CSR to additional_infos
mv ./$output_dir/intermediate_ca.csr.pem ./$output_dir/additional_info/intermediate_ca.csr.pem
# Create CA public chain
cat ./$output_dir/intermediate_ca.cert.pem ./$output_dir/root_ca.cert.pem > ./$output_dir/ca_bundle.crt.pem









