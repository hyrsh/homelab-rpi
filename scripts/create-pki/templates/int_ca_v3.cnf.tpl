[ ca ]                           # The default CA section
default_ca = CA_default          # The default CA name

[ CA_default ]                                                    # Default settings for the intermediate CA
dir               = {{ output_dir }}                              # Intermediate CA directory
certs             = $dir                                          # Certificates directory
crl_dir           = $dir/additional_info                         # CRL directory
new_certs_dir     = $dir/additional_info                         # New certificates directory
database          = $dir/additional_info/index_intermediate.txt  # Certificate index file
serial            = $dir/additional_info/serial_intermediate     # Serial number file
RANDFILE          = $dir/additional_info/.rand_intermediate      # Random number file
private_key       = $dir/intermediate_ca.key.pem                  # Intermediate CA private key
certificate       = $dir/intermediate_ca.cert.pem                 # Intermediate CA certificate
crl               = $dir/additional_info/intermediate.crl.pem    # Intermediate CA CRL
crlnumber         = $dir/additional_info/crlnumber_intermediate  # Intermediate CA CRL number
crl_extensions    = crl_ext                                       # CRL extensions
default_crl_days  = 30                                            # Default CRL validity days
default_md        = sha256                                        # Default message digest
preserve          = no                                            # Preserve existing extensions
email_in_dn       = no                                            # Exclude email from the DN
name_opt          = ca_default                                    # Formatting options for names
cert_opt          = ca_default                                    # Certificate output options
policy            = policy_loose                                  # Certificate policy

[ policy_loose ]                                                  # Policy for less strict validation
countryName             = optional                                # Country is optional
stateOrProvinceName     = optional                                # State or province is optional
localityName            = optional                                # Locality is optional
organizationName        = optional                                # Organization is optional
organizationalUnitName  = optional                                # Organizational unit is optional
commonName              = supplied                                # Must provide a common name
emailAddress            = optional                                # Email address is optional

[ req ]                                                           # Request settings
default_bits        = 4096                                        # Default key size
distinguished_name  = dn                                          # Default DN template
string_mask         = utf8only                                    # UTF-8 encoding
default_md          = sha256                                      # Default message digest
x509_extensions     = v3_intermediate_ca                          # Extensions for intermediate CA certificate
prompt              = no

[ dn ]                               # Template for the DN in the CSR
C             = {{ srv_country }}
ST            = {{ srv_state }}
L             = {{ srv_loc }}
O             = {{ srv_org }}
OU            = {{ srv_ou }}
CN            = {{ domain }}
emailAddress  = {{ srv_mail }}

[ v3_intermediate_ca ]                                      # Intermediate CA certificate extensions
subjectKeyIdentifier = hash                                 # Subject key identifier
authorityKeyIdentifier = keyid:always,issuer                # Authority key identifier
basicConstraints = critical, CA:true, pathlen:0             # Basic constraints for a CA
keyUsage = critical, digitalSignature, cRLSign, keyCertSign # Key usage for a CA

[ crl_ext ]                                                 # CRL extensions
authorityKeyIdentifier=keyid:always                         # Authority key identifier

[ server_cert ]                                             # Server certificate extensions
basicConstraints = CA:FALSE                                 # Not a CA certificate
nsCertType = server                                         # Server certificate type
keyUsage = critical, digitalSignature, keyEncipherment      # Key usage for a server cert
extendedKeyUsage = serverAuth                               # Extended key usage for server authentication purposes (e.g., TLS/SSL servers).
authorityKeyIdentifier = keyid,issuer                       # Authority key identifier linking the certificate to the issuer's public key.
