#!/bin/sh
#set -x

mkdir -p out

getMaistra() {
    maistraBranch=$(yq read data/release.yaml maistraBranch)
    maistraVersion=$(yq read data/release.yaml maistraOperatorVersion)

    wget https://raw.githubusercontent.com/Maistra/istio-operator/${maistraBranch}/resources/smcp-templates/v${maistraVersion}/base -O out/base
    wget https://raw.githubusercontent.com/Maistra/istio-operator/${maistraBranch}/resources/smcp-templates/v${maistraVersion}/servicemesh -O out/servicemesh
    wget https://raw.githubusercontent.com/Maistra/istio-operator/${maistraBranch}/resources/smcp-templates/v${maistraVersion}/maistra -O out/maistra
    yq merge out/base out/maistra > out/maistra.rendered
    yq merge out/base out/servicemesh > out/servicemesh.rendered
}

getKiali() {
    file=out/kiali.rendered

    wget https://raw.githubusercontent.com/kiali/kiali-operator/master/deploy/kiali/kiali_cr.yaml -O ${file}

    MatchingLines=$(grep -nr "#[[:blank:]]* ---" ${file} | cut -d : -f1 )

    for lineNumber in $MatchingLines; do
        #our line number is the match (---). Skip it.
        lineNumber=$((${lineNumber}+1))

        #find the next line matching ## or # letter (only one space)
        lineNumberEnd=$(tail -n +$lineNumber ${file} | grep -n -E '##+|#[[:space:]][*a-zA-Z]|#[[:space:]]*---'  | cut -d : -f1 | head -1 )

        #decrement linenumberend and combine it with linenumber since it's an offset
        lineNumberEnd=$((${lineNumber} + ${lineNumberEnd} - 2))
        if [[ -z $lineNumberEnd ]]; then
			#HACK: this number should be bigger than any length the file might be. It just tells the sed to go past the end of the file.
            lineNumberEnd=5000000
        fi

        sed -i "${lineNumber},${lineNumberEnd}s/#//" ${file}
    done
}

getValue() {
    yq read out/$1.rendered $2
}

updateValuesFile() {
    input=$1
    replace=""
    while IFS= read -r line
    do
        if [[ $replace ]]; then
            echo "replacing: ${line} with: ${replace}"
            echo ""

            lineValues=($line)
            argName=${lineValues[0]}
            sed -i "s#${argName}.*#${argName} ${replace}#" ${input}

            replace=""
        fi
        if [[ $line == *"//Value"* ]]; then
            match=$line
            matchValues=($match)
            specFile=${matchValues[1]}
            specPath=${matchValues[2]}
            replace=$(getValue ${specFile} ${specPath})
            echo "GetValue ${specPath} from ${specFile}. Value: ${replace}"
        fi
    done < "$input"
}


getMaistra
getKiali
updateValuesFile $1
