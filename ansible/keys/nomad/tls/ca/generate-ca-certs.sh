#!/bin/bash

cfssl print-defaults csr | cfssl gencert -initca - | cfssljson -bare nomad-ca
