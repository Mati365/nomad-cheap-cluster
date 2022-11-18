#!/bin/bash

export ADVERT_IP=$(ip --json addr show | jq -r '.[] | select(.ifname=="{{ ip.interface.default }}") | .addr_info[0].local')
sed "s/ADVERT_IP_ADDR/$ADVERT_IP/g" {{ consul.remote.server.root_dir }}/server.hcl > {{ consul.remote.server.root_dir }}/server-parsed.hcl
