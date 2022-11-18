#!/bin/bash

(cd ca/; ./generate-ca-certs.sh)

[[ -d client/ ]] && rm -rf client/
[[ -d server/ ]] && rm -rf server/

mkdir client server

echo '{}' | cfssl gencert -ca=./ca/vault-ca.pem -ca-key=./ca/vault-ca-key.pem -config=./cfssl.json \
  -hostname="vault.service.consul,localhost,127.0.0.1" - | cfssljson -bare server/server

echo '{}' | cfssl gencert -ca=./ca/vault-ca.pem -ca-key=./ca/vault-ca-key.pem -config=./cfssl.json \
  -hostname="vault.service.consul,localhost,127.0.0.1" - | cfssljson -bare client/client
