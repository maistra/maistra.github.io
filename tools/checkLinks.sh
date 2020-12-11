#!/bin/bash
set -e -x

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# shellcheck disable=SC1090
source "${DIR}/check-yq.sh"

export LC_ALL=C.UTF-8

#note that release information must be checked before cding to the generated site data
maistraVersion=$(${YQ} read data/release.yaml maistraVersion)
maistraBranch=$(${YQ} read "data/releases/${maistraVersion}.yaml" maistraBranch)

#get number of commits on branch so that we can detect new files even past the current commit
commitsOnBranch=$(git rev-list --count --bisect "${maistraBranch}")

#list both added and renamed files
newFiles=$(git diff --diff-filter=AR HEAD~"${commitsOnBranch}" --name-only)
echo "Link checker detected the following new files: ${newFiles}. Edit links for these will be ignored."

if [ -z "${newFiles}" ]; then
	echo "No new files"
else
	additionalIgnoredLinks=$(echo "${newFiles}" | \
		# take all lines and prepend the maistra URL on them
		awk -v s='https://github.com/Maistra/maistra.github.io/edit/'"${maistraBranch}"'/' '{print s$1}' | \
		# convert lines into a comma separate list
		paste -s -d ',')
fi

hugo -D
cd public
echo "Link checker additionally ignoring the following links:${additionalIgnoredLinks}"

# shellcheck disable=SC2140
htmlproofer --url-ignore "https://docs.openshift.com/container-platform/4.6/installing/installing_vsphere/installing-vsphere.html#installing-vsphere","https://docs.openshift.com/container-platform/4.6/installing/installing_bare_metal/installing-bare-metal.html#installing-bare-metal","https://docs.openshift.com/container-platform/4.6/installing/installing_aws/installing-aws-user-infra.html#installing-aws-user-infra","https://docs.openshift.com/container-platform/4.6/installing/installing_aws/installing-aws-account.html#installing-aws-account","#","http://prometheus-istio-system.127.0.0.1.nip.io","http://getgrav.org","#installing-aws-account","${additionalIgnoredLinks}" --http-status-ignore 302,301 --assume-extension --check-external-hash  ., ../README.adoc


