#!/bin/bash

(cd tls; ./generate-certs.sh)
./utils/generate-bootstrap-key.sh > token.key
