#!/bin/sh
set -e -x

export LC_ALL=C.UTF-8
hugo -D
cd public

# shellcheck disable=SC2140
htmlproofer --url-ignore "#","http://prometheus-istio-system.127.0.0.1.nip.io","http://getgrav.org" --assume-extension --check-external-hash ., ../README.adoc
