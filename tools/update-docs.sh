#!/bin/sh

set -x

# shellcheck disable=SC2039
DIR="$( pwd )"

wget https://raw.githubusercontent.com/openshift/openshift-docs/master/_topic_map.yml

# shellcheck disable=SC2002
cat _topic_map.yml | yq 'select(.Name=="Service Mesh").Topics[] | select (.Name == "Service Mesh 2.x").Topics' > topics.yml

rm _topic_map.yml
go run "${DIR}/tools/update-docs.go" --docsPath "${DIR}/topics/docs" --modulesPath "${DIR}"

#for file in patches/*
#do
#    git apply "${DIR}/../${file}"
#done
