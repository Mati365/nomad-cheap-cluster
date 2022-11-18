#!/bin/bash

function key {
  echo $RANDOM | md5sum | head -c $1
}

echo "$(key 8)-$(key 4)-$(key 4)-$(key 4)-$(key 12)"
