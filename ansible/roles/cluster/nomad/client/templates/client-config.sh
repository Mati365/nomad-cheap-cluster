#!/bin/bash

export ADVERT_IP=$(ip --json addr show | jq -r '.[] | select(.ifname=="{{ cluster_interface }}") | .addr_info[0].local')

sed "s/ADVERT_IP_ADDR/$ADVERT_IP/g" {{ nomad.remote.client.root_dir }}/config.hcl > {{ nomad.remote.client.root_dir }}/config-parsed.hcl
