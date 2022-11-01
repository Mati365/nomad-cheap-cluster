#!/bin/bash

rm -rf ./ca ./client ./server
mkdir -p ca client server

# Generate CA
(cd ca/; consul tls ca create)

# Generate server key
(cd server/; consul tls cert create -server -dc="dc1" -ca="../ca/consul-agent-ca.pem"  -key="../ca/consul-agent-ca-key.pem")

# Generate Client key
(cd client/; consul tls cert create -client -dc="dc1" -ca="../ca/consul-agent-ca.pem"  -key="../ca/consul-agent-ca-key.pem")
