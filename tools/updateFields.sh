#!/bin/bash
set -e -x

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# shellcheck disable=SC1090
source "${DIR}/check-yq.sh"

mkdir -p out

getMaistra() {
		maistraVersion=$(${YQ} read data/release.yaml maistraVersion)
    maistraBranch=$(${YQ} read "data/releases/${maistraVersion}.yaml" maistraBranch)
    maistraVersion=$(${YQ} read "data/releases/${maistraVersion}.yaml" maistraOperatorVersion)

    wget "https://raw.githubusercontent.com/Maistra/istio-operator/${maistraBranch}/resources/smcp-templates/v${maistraVersion}/base" -O out/base
    wget "https://raw.githubusercontent.com/Maistra/istio-operator/${maistraBranch}/resources/smcp-templates/v${maistraVersion}/servicemesh" -O out/servicemesh
    wget "https://raw.githubusercontent.com/Maistra/istio-operator/${maistraBranch}/resources/smcp-templates/v${maistraVersion}/maistra" -O out/maistra
    ${YQ} merge out/base out/maistra > out/maistra.rendered.yaml
    ${YQ} merge out/base out/servicemesh > out/servicemesh.rendered.yaml
}

getKiali() {
    file=out/kiali.rendered.yaml

    wget https://raw.githubusercontent.com/kiali/kiali-operator/master/deploy/kiali/kiali_cr.yaml -O ${file}

    matchingLines=$(grep -nr "#[[:blank:]]* ---" ${file} | cut -d : -f1 )

    for lineNumber in $matchingLines; do
        #our line number is the match (---). Skip it.
        lineNumber=$((lineNumber+1))

        #find the next line matching ## or # letter (only one space)
        lineNumberEnd=$(tail -n +$lineNumber ${file} | grep -n -E '##+|#[[:space:]][*a-zA-Z]|#[[:space:]]*---'  | cut -d : -f1 | head -1 )

        #decrement linenumberend and combine it with linenumber since it's an offset
        lineNumberEnd=$((lineNumber + lineNumberEnd - 2))
        if [ -z $lineNumberEnd ]; then
			#HACK: this number should be bigger than any length the file might be. It just tells the sed to go past the end of the file.
            lineNumberEnd=5000000
        fi

        sed -i "${lineNumber},${lineNumberEnd}s/#//" ${file}
    done
}

getValue() {
    ${YQ} read "out/${1}.rendered.yaml" "${2}"
}

updateValuesFile() {
    input="${1}"
    replace=""
    while IFS= read -r line
    do
        if [ $replace ]; then
            echo "replacing: ${line} with: ${replace}"
            echo ""

            argName=$(echo "${line}" | cut -d' ' -f1)
            sed -i "s#${argName}.*#${argName} ${replace}#" "${input}"

            replace=""
        fi

        #use posix substring to work across shells.
        #this checks to see if ${line} contains "//Value"
        if [ "${line#*//Value}" != "${line}" ]; then
            match=$line
            specFile=$(echo "${match}" | cut -d' ' -f2)
            specPath=$(echo "${match}" | cut -d' ' -f3)
            replace=$(getValue "${specFile}" "${specPath}")
            echo "GetValue ${specPath} from ${specFile}. Value: ${replace}"
        fi
    done < "$input"
}


getMaistra
getKiali
updateValuesFile "${1}"
