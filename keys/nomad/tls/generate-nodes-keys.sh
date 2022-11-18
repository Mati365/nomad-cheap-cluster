#!/bin/bash

[[ -d client/ ]] && rm -rf client/
[[ -d server/ ]] && rm -rf server/

mkdir client server

echo '{}' | cfssl gencert -ca=./ca/nomad-ca.pem -ca-key=./ca/nomad-ca-key.pem -config=./cfssl.json \
  -hostname="server.global.nomad,localhost,127.0.0.1" - | cfssljson -bare server/server

echo '{}' | cfssl gencert -ca=./ca/nomad-ca.pem -ca-key=./ca/nomad-ca-key.pem -config=./cfssl.json \
  -hostname="client.global.nomad,localhost,127.0.0.1" - | cfssljson -bare client/client
