#!/bin/bash

(cd ca/; ./generate-ca-certs.sh)
./generate-nodes-keys.sh
