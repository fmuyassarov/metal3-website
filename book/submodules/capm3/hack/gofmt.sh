#!/bin/sh

set -eux

IS_CONTAINER=${IS_CONTAINER:-false}
CONTAINER_RUNTIME="${CONTAINER_RUNTIME:-podman}"

if [ "${IS_CONTAINER}" != "false" ]; then
  export XDG_CACHE_HOME=/tmp/.cache
  mkdir /tmp/unit
  cp -r ./* /tmp/unit
  cd /tmp/unit
  make fmt > /tmp/fmt-output.log
  FILE_LENGTH="$(wc -l /tmp/fmt-output.log | awk '{ print $1 }')"
  if [ "${FILE_LENGTH}" != "1" ]; then
    echo "Formatting error! Please run 'make fmt' to correct the problem."
    echo "The problematic files are listed below, after the command that should be run"
    cat /tmp/fmt-output.log
    exit 1
  fi
else
  "${CONTAINER_RUNTIME}" run --rm \
    --env IS_CONTAINER=TRUE \
    --volume "${PWD}:/go/src/github.com/metal3-io/cluster-api-provider-metal3:ro,z" \
    --entrypoint sh \
    --workdir /go/src/github.com/metal3-io/cluster-api-provider-metal3 \
    registry.hub.docker.com/library/golang:1.13.7 \
    /go/src/github.com/metal3-io/cluster-api-provider-metal3/hack/gofmt.sh
fi;
