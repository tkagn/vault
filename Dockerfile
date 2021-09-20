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

