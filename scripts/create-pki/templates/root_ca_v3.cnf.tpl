[ ca ]                                                   # The default CA section
default_ca = CA_default                                  # The default CA name

[ CA_default ]                                           # Default settings for the CA
dir               = {{ output_dir }}                     # CA directory
certs             = $dir                                 # Certificates directory
crl_dir           = $dir/additional_info                 # CRL directory
new_certs_dir     = $dir/additional_info                 # New certificates directory
database          = $dir/additional_info/index_root.txt  # Certificate index file
serial            = $dir/additional_info/serial_root     # Serial number file
RANDFILE          = $dir/additional_info/.rand_root      # Random number file
private_key       = $dir/root_ca.key.pem                 # Root CA private key
certificate       = $dir/root_ca.cert.pem                # Root CA certificate
crl               = $dir/additional_info/root_ca.crl.pem # Root CA CRL
crlnumber         = $dir/additional_info/crlnumber_root  # Root CA CRL number
crl_extensions    = crl_ext                              # CRL extensions
default_crl_days  = 30                                   # Default CRL validity days
default_md        = sha256                               # Default message digest
preserve          = no                                   # Preserve existing extensions
email_in_dn       = no                                   # Exclude email from the DN
name_opt          = ca_default                           # Formatting options for names
cert_opt          = ca_default                           # Certificate output options
policy            = policy_strict                        # Certificate policy
unique_subject    = no                                   # Allow multiple certs with the same DN

[ policy_strict ]                                        # Policy for stricter validation
countryName             = match                          # Must match the issuer's country
stateOrProvinceName     = match                          # Must match the issuer's state
organizationName        = match                          # Must match the issuer's organization
organizationalUnitName  = optional                       # Organizational unit is optional
commonName              = supplied                       # Must provide a common name
emailAddress            = optional                       # Email address is optional

[ req ]                                                  # Request settings
default_bits        = 4096                               # Default key size
distinguished_name  = req_distinguished_name             # Default DN template
string_mask         = utf8only                           # UTF-8 encoding
default_md          = sha256                             # Default message digest
prompt              = no                                 # Non-interactive mode

[ req_distinguished_name ]                               # Template for the DN in the CSR
countryName                     = Country Name (2 letter code)
stateOrProvinceName             = State or Province Name (full name)
localityName                    = Locality Name (city)
0.organizationName              = Organization Name (company)
organizationalUnitName          = Organizational Unit Name (section)
commonName                      = Common Name (your domain)
emailAddress                    = Email Address

[ v3_ca ]                                           # Root CA certificate extensions
subjectKeyIdentifier = hash                         # Subject key identifier
authorityKeyIdentifier = keyid:always,issuer        # Authority key identifier
basicConstraints = critical, CA:true                # Basic constraints for a CA
keyUsage = critical, keyCertSign, cRLSign           # Key usage for a CA

[ crl_ext ]                                         # CRL extensions
authorityKeyIdentifier = keyid:always,issuer        # Authority key identifier

[ v3_intermediate_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true, pathlen:0
keyUsage = critical, digitalSignature, cRLSign, keyCertSign
