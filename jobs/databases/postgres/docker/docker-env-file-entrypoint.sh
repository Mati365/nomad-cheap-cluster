#!/usr/bin/env bash

export $(grep -v '^#' /etc/db.envs | xargs)

. /usr/local/bin/docker-entrypoint.sh
_main "$@"
