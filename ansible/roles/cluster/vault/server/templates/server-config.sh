#!/bin/bash

export ADVERT_IP=$(ip --json addr show | jq -r '.[] | select(.ifname=="{{ cluster_interface }}") | .addr_info[0].local')

/sbin/setcap 'cap_ipc_lock=+ep' /usr/bin/vault
sed "s/ADVERT_IP_ADDR/$ADVERT_IP/g" {{ vault.remote.server.root_dir }}/config.hcl > {{ vault.remote.server.root_dir }}/config-parsed.hcl
