package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"net/http"
	"path"
	"regexp"
	"strings"
)

type topic struct {
	Name string `json:"Name"`
	File string `json:"File"`
}

type docsReplacer func(string) string

func getStringReplacer(entry string, replaceWith string) docsReplacer {
	return func(body string) string {
		fmt.Printf("replacing %s with %s\n", entry, replaceWith)
		return strings.ReplaceAll(body, entry, replaceWith)
	}
}

func getRegexStringReplacer(entry *regexp.Regexp, replaceWith string) docsReplacer {
	return func(body string) string {
		fmt.Printf("replacing %s with %s\n", entry, replaceWith)
		return entry.ReplaceAllString(body, replaceWith)
	}
}

func getHeaderReplacer(title string, weight int) docsReplacer {
	return func(body string) string {
		return `---
title: ` + title + `
type: "document"
weight: ` + fmt.Sprintf("%d", weight) + `
---

` + body
	}
}

func convertExternalURLs(body string) string {

	//match ../../
	urlRegexp := regexp.MustCompile("xref:\\.\\.\\/\\.\\.\\/.*")
	results := urlRegexp.FindAllString(body, -1)
	for _, result := range results {
		//convert docs to use OpenShift URL
		replacement := strings.Replace(result, "xref:../../", "link:https://docs.openshift.com/container-platform/4.6/", -1)

		//replace .adoc with .html
		replacement = strings.Replace(replacement, ".adoc", ".html", 1)

		fmt.Printf("updating URL %s with %s\n", result, replacement)
		//now repopulate
		body = strings.ReplaceAll(body, result, replacement)
	}
	return body
}

var (
	baseURL         string = "https://raw.githubusercontent.com/openshift/openshift-docs/master/"
	modulesPath     string = baseURL
	docsPath        string = baseURL + "service_mesh/v2x/"
	docsFilePath    string
	modulesFilePath string
	docsReplacers   = []docsReplacer{
		getStringReplacer("../../service_mesh/v2x", "/docs"),
		getStringReplacer("[source,terminal]", "[source,bash]"),
		convertExternalURLs,
	}
)

func init() {
	flag.StringVar(&docsFilePath, "docsPath", ".", "path to download docs files to")
	flag.StringVar(&modulesFilePath, "modulesPath", ".", "path to download module files to")
	flag.Parse()
}

func main() {
	fmt.Printf("docsFilePath is %s\n", docsFilePath)
	fmt.Printf("modulesFilePath is %s\n", modulesFilePath)
	data, err := ioutil.ReadFile("topics.yml")
	if err != nil {
		fmt.Printf("Unable to process topics.yml:%s\n", err.Error())
		return
	}

	var topics []topic
	if err = json.Unmarshal(data, &topics); err != nil {
		fmt.Printf("Unable to unmarshal JSON: %s", err.Error())
		return
	}

	//question: are there recursive matches?
	i := 1
	for _, topic := range topics {
		fileName := topic.File + ".adoc"
		fmt.Printf("downloading:%+v\n\n\n", fileName)
		topicURL := docsPath + fileName

		includesRegexp := regexp.MustCompile("include::[A-Za-z\\/\\-.]*")
		imageRegexp := regexp.MustCompile("image::[A-Za-z\\/\\-.]*\\[")
		var matches []string = make([]string, 0, 0)
		if matches, err = downloadDoc(topicURL, topic.Name, i, path.Join(docsFilePath, fileName), []regexp.Regexp{*includesRegexp, *imageRegexp}); err != nil {
			fmt.Printf("failed to download %s: %s\n", topicURL, err.Error())
		}

		i++

		for _, match := range matches {
			match := match[len("include::"):]
			moduleURL := modulesPath + match
			downloadPath := path.Join(modulesFilePath, match)
			//todo: refactor to be recursive
			//todo: refactor to use single function for image, doc, module
			//todo: fix warnings
			fmt.Printf("downloading module %s \n\tfrom %s \n\tto %s \n", match, moduleURL, match)
			if strings.Contains(match, "image::") {
				fmt.Printf("downloading image: %s", downloadPath)
				if _, err := downloadImage(moduleURL, downloadPath, []regexp.Regexp{}); err != nil {
					fmt.Printf("failed to download %s: %s\n", moduleURL, err.Error())
				}
			} else if matches, err = downloadModule(moduleURL, downloadPath, []regexp.Regexp{*includesRegexp, *imageRegexp}); err != nil {
				fmt.Printf("failed to download %s: %s\n", moduleURL, err.Error())
			}
			fmt.Printf("matches: %+v\n\n", matches)
		}
	}
}

func getFile(url string) ([]byte, error) {
	response, err := http.Get(url)
	if err != nil {
		return nil, fmt.Errorf("failed to download: %s", err)
	}
	defer response.Body.Close()

	if response.StatusCode != 200 {
		return nil, fmt.Errorf("Received %d when expecting 200", response.StatusCode)
	}

	body, err := ioutil.ReadAll(response.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read body: %s", err.Error())
	}
	return body, nil
}

func convertDoc(body string, replaceInDocs []docsReplacer) string {
	for _, replaceWith := range replaceInDocs {
		body = replaceWith(body)
	}

	return body
}

func findDocReferences(body string, toMatch []regexp.Regexp) ([]string, error) {
	matches := []string{}
	for _, regex := range toMatch {
		matches = append(matches, regex.FindAllString(body, -1)...)
	}
	return matches, nil
}

func downloadDoc(url string, title string, weight int, filename string, toMatch []regexp.Regexp) ([]string, error) {

	body, err := getFile(url)
	if err != nil {
		return []string{}, err
	}
	bodyAsString := string(body)

	//convert doc as necessary to meet differences between Maistra and OSSM
	bodyAsString = convertDoc(bodyAsString, docsReplacers)

	//add header
	bodyAsString = getHeaderReplacer(strings.Replace(title, "Service Mesh", "Maistra", -1), weight)(bodyAsString)

	err = ioutil.WriteFile(filename, []byte(bodyAsString), 0644)
	if err != nil {
		return []string{}, fmt.Errorf("failed to write file: %s", err)
	}

	return findDocReferences(bodyAsString, toMatch)

}

func downloadImage(url string, filename string, toMatch []regexp.Regexp) ([]string, error) {
	body, err := getFile(url)
	if err != nil {
		return []string{}, err
	}

	err = ioutil.WriteFile(filename, []byte(body), 0644)
	if err != nil {
		return []string{}, fmt.Errorf("failed to write file: %s", err)
	}
	return []string{}, nil

}

func downloadModule(url string, filename string, toMatch []regexp.Regexp) ([]string, error) {

	body, err := getFile(url)
	if err != nil {
		return []string{}, err
	}
	bodyAsString := string(body)

	//hacky but populates it
	fmt.Printf("module filename: %s", path.Base(filename))
	if path.Base(filename) == "ossm-document-attributes.adoc" {
		fmt.Printf("Found a match")
		bodyAsString += ":product-version: 4.6"
		bodyAsString = getRegexStringReplacer(regexp.MustCompile(":ProductShortName:.*"), ":ProductShortName: Maistra")(bodyAsString)
		bodyAsString = getRegexStringReplacer(regexp.MustCompile(":ProductName:.*"), ":ProductName: Maistra Service Mesh")(bodyAsString)
		bodyAsString = getRegexStringReplacer(regexp.MustCompile(":Install_BookName:.*"), ":Install_BookName: Installing Maistra")(bodyAsString)
		bodyAsString = getRegexStringReplacer(regexp.MustCompile(":RN_BookName:.*"), ":RN_BookName: Installing Maistra")(bodyAsString)
		bodyAsString = getRegexStringReplacer(regexp.MustCompile(":DocInfoProductName:.*"), ":DocInfoProductName: Maistra")(bodyAsString)

	}

	//convert doc as necessary to meet differences between Maistra and OSSM
	bodyAsString = convertDoc(bodyAsString, docsReplacers)

	err = ioutil.WriteFile(filename, []byte(bodyAsString), 0644)
	if err != nil {
		return []string{}, fmt.Errorf("failed to write file: %s", err)
	}

	return findDocReferences(bodyAsString, toMatch)
}
