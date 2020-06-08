#!/bin/sh
set -e -x

export LC_ALL=C.UTF-8

#note that release information must be checked before cding to the generated site data
maistraVersion=$(yq read data/release.yaml maistraVersion)
maistraBranch=$(yq read "data/releases/${maistraVersion}.yaml" maistraBranch)

#get number of commits on branch so that we can detect new files even past the current commit
commitsOnBranch=$(git rev-list --count --bisect "${maistraBranch}")

#
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
htmlproofer --url-ignore "#","http://prometheus-istio-system.127.0.0.1.nip.io","http://getgrav.org","${additionalIgnoredLinks}" --assume-extension --check-external-hash ., ../README.adoc
