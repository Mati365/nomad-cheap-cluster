#!/bin/bash

cfssl print-defaults csr | cfssl gencert -initca - | cfssljson -bare vault-ca
