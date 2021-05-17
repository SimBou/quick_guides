# CERTIFICATES
## Table of Contents
  - [Create private key](#create-private-key)
  - [Create CSR (Certificate Signing Request)](#create-a-crs-file-with-private-secured-key)
  - [Create certificate](#create-certificate)
  - [Display and check certificate](#display-and-check-certificate)
  - [Convert certificates](#convert-certificates)
  - [Add certificate to java keystore](#add-certificate-to-java-keystore)
  - [References](#references)
## Create Private Key

RSA private key
```commandline
openssl genrsa
```
RSA private key 2048 bits in out file
```commandline
openssl genrsa -out certificate.key 2048
```
DES3 private key
```commandline
openssl genrsa -des3 -out certificate.key 2048
```
Public key with input private key
```commandline
openssl rsa -in certificate.key -pubout
```
DSA private key
```commandline
openssl dsaparam -out dsaparam.pem 2048
openssl gendsa -des3 -out certificate.key dsaparam.pem
```
ECC private key
```commandline
openssl ecparam -out certificate.key -name prime256v1 -genkey
```
Remove pass-phrase on private key
```commandline
openssl rsa -in certificate.key -out certificate.lockout.key
```
## Create a CRS file (with private secured key)
```commandline
openssl req -new -key certificate.key -out certificat.csr
openssl req -new -sha256 -key www.server.com.key -out www.server.com.csr
```
## Create certificate
Create auto-sign certificate using our previously generated csr and key
```commandline
openssl x509 -req -days 365 -in certificat.csr -signkey certificat.key -out certificat.crt
```
Other commands and options
```commandline
openssl req -sha256 -nodes -newkey rsa:2048 -keyout www.server.com.key -out www.server.com.csr
openssl req -x509 -newkey rsa:2048 -nodes -keyout www.server.com.key -out www.server.com.crt -days 365
```
## Display and check certificate
Check and display CSR file
```commandline
openssl req -noout -text -verify -in www.myserver.com.csr
```
Check and display private and public key
```commandline
openssl rsa -noout -text -check -in www.server.com.key
```
Display PEM certificate
```commandline
openssl x509 -noout -text -in www.server.com.crt
```
Display PKCS7 certificate
```commandline
openssl pkcs7 -print_certs -in www.server.com.p7b
```
Display PKCS12 certificate
```commandline
openssl pkcs12 -info -in www.server.com.pfx
```
Check and display certificate with SSL connexion
```commandline
openssl s_client -connect www.server.com:443
```
Check if a certificate and CSR use the same public key
```commandline
openssl x509 -noout -modulus www.server.com.crt | openssl sha256
openssl req -noout -modulus www.server.com.csr | openssl sha256
openssl rsa -noout -modulus www.server.com.key | openssl sha256
```
## Convert certificates
Convert PKCS12 (.pfx, .p12 used by Windows) to PEM (used by Linux)
```commandline
openssl pkcs12 -nodes -in www.server.com.pfx -out www.server.com.crt
```
Convert PEM to PKCS12
```commandline
openssl pkcs12 -export -in www.server.com.crt -inkey www.server.com.key -out www.server.com.pfx
```
Convert PKCS7 to PEM
```commandline
openssl pkcs7 -print_certs -in www.server.com.p7b -out www.server.com.crt
```
Convert PEM to PKCS7
```commandline
openssl crl2pkcs7 -nocrl -certfile www.server.com.crt -out www.server.com.p7b
```
Convert DER (.crt .cer ou .der) to PEM
```commandline
openssl x509 -inform der -in certificate.cer -out certificate.pem
```

## Add certificate to java keystore
Convert PEM to PKCS12
```commandline
openssl pkcs12 -export -in /etc/gitlab/ssl/__axelit_fr_ee.crt -inkey /etc/gitlab/ssl/__axelit_fr.key -name automation.axelit.fr -out __axelit_fr.p12
```
Import PKCS12 to KEYSTORE
```commandline
keytool -importkeystore -srckeystore __axelit_fr.p12 -srcstoretype PKCS12 -deststoretype pkcs12 -keystore keystore -keypass adminadmin -storepass adminadmin
keytool -import -alias rundeck -trustcacerts -file wildcard.axelit.fr.ca -keystore keystore
```

## References
https://www.kinamo.fr/fr/support/faq/commandes-openssl-utiles

https://www.remipoignon.fr/generez-un-certificat-ssl-auto-signe-pour-passer-en-https/

https://www.quennec.fr/trucs-astuces/syst%C3%A8mes/gnulinux/commandes/openssl/openssl-g%C3%A9n%C3%A9rer-un-certificat-auto-sign%C3%A9
