#!/bin/bash

export ADVERT_IP=$(ip --json addr show | jq -r '.[] | select(.ifname=="{{ ip.interface.default }}") | .addr_info[0].local')
export NODE_ID=$(echo $ADVERT_IP | base64)

sed "s/ADVERT_IP_ADDR/$ADVERT_IP/g" {{ consul.remote.client.root_dir }}/node.hcl > {{ consul.remote.client.root_dir }}/node-parsed.hcl
sed -i "s/NODE_ID/$NODE_ID/g" {{ consul.remote.client.root_dir }}/node-parsed.hcl
