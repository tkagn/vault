# Vault Setup

### Generate PKI Infrastructure

```bash
# Build CA 
openssl genrsa 4096 > ca.key
openssl req -x509 -new -key ./ca.key -nodes -days 365 -out ca.pem -subj "/CN=Vault Internal CA" 

# Generate exenstion file for client PKI
cat << EOF >> vault.ext
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1=vault1.tkagn.internal
DNS.2=vault1
DNS.3=vault2.tkagn.internal
DNS.4=vault2
DNS.5=vault3.tkagn.internal
DNS.6=vault3
IP.1=127.0.0.1
EOF

#Build client wildcard crt and key
openssl genrsa 4096 > vault.key
openssl req -new -key vault.key -subj "/CN=*.tkagn.internal" -out vault.csr
openssl x509 -req -in vault.csr -CA ca.pem -CAkey ca.key -days 365 -CAcreateserial -extfile vault.ext -out vault.pem
openssl x509 -in vault.pem -noout -text 
```
### Generate Storage Files

```bash
mkdir vault
cd vault
for i in {1..3} ; do fallocate -l 25MB vault-disk-${i}.disk ; done
```

### Download Vault

```bash
cd vault
wget 'https://releases.hashicorp.com/vault/1.8.2/vault_1.8.2_linux_amd64.zip'
wget 'https://releases.hashicorp.com/vault/1.8.2/vault_1.8.2_SHA256SUMS'
sha25sum -c vault_1.8.2_SHA256SUMS vault_1.8.2_linux_amd64.zip
unzip ./vault_1.8.2_linux_amd64.zip
rm vault_1.8.2_linux_amd64.zip
```
> (U+1F4DD) [**NOTE**] Be sure the checksum check reports 'ok'  

### Build Vault Container Image

vi ./Dockerfile:

```text
FROM docker.io/library/alpine

RUN apk update \
&& apk upgrade \
&& apk add openssl \
&& apk cache clean

RUN mkdir -p /vault/logs && \
    mkdir -p /vault/file && \
    mkdir -p /vault/config && \
    mkdir -p /vault/storage && \
    mkdir -p /vault/tls && \
    export PATH=$PATH:/vault

WORKDIR /vault
cd /vault
cp vault /vault
cp vault.hcl /vault/config/
cp ./ca/ca.pem /vault/tls/
cp ./ca/vault.pem /vault/tls/
cp ./ca/vault.key /vault/tls/


EXPOSE 8200
EXPOSE 8231

ENTRYPOINT [ 'vault' ]
CMD [ 'server ', '-config /vault/config/vault.hcl' ]
```

podman build -t localhost/vault:1.8.2 .


### Initialize Vault

export VAULT_ADDR=127.0.0.1
vault init -address=${VAULT_ADDR} > keys.txt
