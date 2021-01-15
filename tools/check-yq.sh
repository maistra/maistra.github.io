#!/bin/bash

# Looks for yq-go (https://github.com/mikefarah/yq) first, as installed in CI image, fallbacks to yq.
# Note there's another yq package, written in python, which is not the one we want: https://github.com/kislyuk/yq
# https://issues.redhat.com/browse/MAISTRA-1717
# shellcheck disable=SC2230
YQ=$(which yq-go 2>/dev/null || which yq 2>/dev/null || echo "")

if ! [ -x "$(command -v "${YQ}")" ]; then
  echo "Please install the golang yq package"
  exit 1
else
  s="yq version 3.*"
  if ! [[ $(${YQ} --version) =~ $s ]]; then
    echo "Install the correct (golang) yq package"
    exit 1
  fi
fi

export YQ
