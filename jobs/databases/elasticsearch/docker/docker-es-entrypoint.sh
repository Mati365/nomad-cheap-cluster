#!/usr/bin/env bash

chown -R elasticsearch:elasticsearch /usr/share/elasticsearch/data
chmod -R 777 /usr/share/elasticsearch/data

su -c "env xpack.security.enabled='false' cluster.name='es-cluster' discovery.type='single-node' /usr/local/bin/docker-entrypoint.sh" elasticsearch
