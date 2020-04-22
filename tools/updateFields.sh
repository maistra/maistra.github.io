#!/bin/sh
set -x

mkdir -p out
maistraBranch=$(yq read data/release.yaml maistraBranch)
maistraVersion=$(yq read data/release.yaml maistraOperatorVersion)

wget https://raw.githubusercontent.com/Maistra/istio-operator/${maistraBranch}/resources/smcp-templates/v${maistraVersion}/base -O out/base
wget https://raw.githubusercontent.com/Maistra/istio-operator/${maistraBranch}/resources/smcp-templates/v${maistraVersion}/servicemesh -O out/servicemesh
wget https://raw.githubusercontent.com/Maistra/istio-operator/${maistraBranch}/resources/smcp-templates/v${maistraVersion}/maistra -O out/maistra
yq merge out/base out/maistra > out/maistra.rendered
yq merge out/base out/servicemesh > out/servicemesh.rendered

getValue() {
	yq read out/$1.rendered $2
}

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

