#!/bin/bash

ARCH=$(uname -m)
if [ -z "$ARCH" ]; then
  echo "Error: Unable to determine architecture"
  exit 1
fi

if [ "$ARCH" = "arm64" ]; then
  export TYPESENSE_IMAGE=${TYPESENSE_IMAGE:-"docker.io/typesense/typesense:0.25.2-arm64"}
else
  export TYPESENSE_IMAGE=${TYPESENSE_IMAGE:-"docker.io/typesense/typesense:0.25.2"}
fi

docker-compose up -d