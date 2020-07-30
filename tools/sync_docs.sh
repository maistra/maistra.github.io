#!/bin/bash
openshiftDocsSha=86082611684bee24698a536f291cf83628aba24b
maistraDocsDir=$(pwd)
pushd $(mktemp -d)
git clone https://github.com/openshift/openshift-docs.git
pushd openshift-docs
git checkout ${openshiftDocsSha}
cp -R service_mesh/* ${maistraDocsDir}/topics/docs2/
popd
popd
