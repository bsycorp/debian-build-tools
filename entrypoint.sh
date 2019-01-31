#!/bin/bash

if test ! -z "$DOCKER"; then
  set -e
  echo "Starting docker daemon..."
  /usr/bin/dockerd --host=unix:///var/run/docker.sock &>/var/log/docker.log &

  tries=0
  d_timeout=20
  until docker info >/dev/null 2>&1
  do
    if [ "$tries" -gt "$d_timeout" ]; then
      cat /var/log/docker.log
      echo 'Timed out trying to connect to internal docker host.' >&2
      exit 1
    fi
    tries=$(( $tries + 1 ))
    sleep 1
  done
  echo "Docker is ready."
fi

eval "$@"
