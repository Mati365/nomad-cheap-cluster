#!/bin/bash

cd "$(dirname "$0")/pulumi/aws/ansible-config-bucket"
pulumi up
