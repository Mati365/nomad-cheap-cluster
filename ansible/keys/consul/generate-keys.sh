#!/bin/bash

rm -rf ./*.key
(cd tls; ./generate-certs.sh)
echo "$(echo $RANDOM | md5sum | head -c 32)" > ./gossip-encryption.key
