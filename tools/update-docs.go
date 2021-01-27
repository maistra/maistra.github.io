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

func getHeaderReplacer(title string, id string, weight int) docsReplacer {
	return getPrependReplacer(getHeader(title, id, weight))
}

func getHeader(title string, id string, weight int) string {
	return `---
title: ` + title + `
type: "document"
id: ` + id + `
weight: ` + fmt.Sprintf("%d", weight) + `
---

`
}

func getDocID(body string) string {
	idRegex := regexp.MustCompile("\\[id=.*\\]")
	id := idRegex.FindString(body)
	if id != "" {
		return id[4 : len(id)-1]
	}
	return ""
}

func getPrependReplacer(content string) docsReplacer {
	return func(body string) string {
		return content + body
	}
}

func getAppendReplacer(content string) docsReplacer {
	return func(body string) string {
		return body + content
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
	imagePath       string = baseURL + "images/"
	docsPath        string = baseURL + "service_mesh/v2x/"
	docsFilePath    string
	modulesFilePath string
	docsReplacers   = []docsReplacer{
		getStringReplacer("../../service_mesh/v2x", "/docs"),
		getStringReplacer("[source,terminal]", "[source,bash]"),
		convertExternalURLs,
	}

	includesRegexp *regexp.Regexp = regexp.MustCompile("include::[A-Za-z\\/\\-.]*")
	imageRegexp    *regexp.Regexp = regexp.MustCompile("image::[A-Za-z\\/\\-.]*")

	//kebab is a special case. Doesn't really match anything else and doing a match of just image: would also fetch docker image content
	kebabImageRegexp *regexp.Regexp = regexp.MustCompile(":kebab:[ ]*image:[A-Za-z\\.\\/-]*")
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

	i := 1
	for _, topic := range topics {
		fileName := topic.File + ".adoc"
		fmt.Printf("downloading:%+v\n\n\n", fileName)
		topicURL := docsPath + fileName
		var matches []string = make([]string, 0, 0)
		if matches, err = downloadFile("doc", topic.Name, i, topicURL, path.Join(docsFilePath, fileName), []regexp.Regexp{*includesRegexp, *imageRegexp}); err != nil {
			fmt.Printf("failed to download (%s): %s\n", topicURL, err.Error())
		}

		processIncludes(matches)
		fmt.Printf("matches: %+v\n\n", matches)
		i++

	}
}

func processIncludes(matches []string) {
	for _, match := range matches {
		//todo: fix warnings
		var matches []string
		var err error
		fmt.Printf("checking %s\n", match)
		if strings.Contains(match, "image::") || strings.Contains(match, ":kebab: image:") {
			if strings.Contains(match, "image::") {
				match = match[len("image::"):]
			} else if strings.Contains(match, ":kebab: image:") {
				match = match[len(":kebab: image:"):]
			}

			imageURL := imagePath + match
			downloadPath := path.Join(docsFilePath, match)
			fmt.Printf("downloading image: %s\n\tfrom %s \n\tto %s \n", match, imageURL, downloadPath)
			if _, err := downloadFile("image", "", 0, imageURL, downloadPath, []regexp.Regexp{}); err != nil {
				fmt.Printf("failed to download (%s): %s\n", imageURL, err.Error())
				panic("image failed")
			}
		} else if strings.Contains(match, "include::") {
			match := match[len("include::"):]
			moduleURL := modulesPath + match
			downloadPath := path.Join(modulesFilePath, match)

			fmt.Printf("downloading module %s \n\tfrom %s \n\tto %s \n", match, moduleURL, match)
			if matches, err = downloadFile("module", "", 0, moduleURL, downloadPath, []regexp.Regexp{*includesRegexp, *imageRegexp, *kebabImageRegexp}); err != nil {
				fmt.Printf("failed to download (%s): %s\n", moduleURL, err.Error())
				panic("module failed")
			}
		}
		fmt.Printf("matches: %+v\n\n", matches)
		processIncludes(matches)
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

func downloadFile(fileType string, title string, weight int, url string, filename string, toMatch []regexp.Regexp) ([]string, error) {

	body, err := getFile(url)
	if err != nil {
		return []string{}, err
	}

	fileDocsReplacers := docsReplacers
	if fileType == "module" && path.Base(filename) == "ossm-document-attributes.adoc" {
		fileDocsReplacers = append(docsReplacers, []docsReplacer{
			getAppendReplacer(":product-version: 4.6"),
			getRegexStringReplacer(regexp.MustCompile(":ProductShortName:.*"), ":ProductShortName: Maistra"),
			getRegexStringReplacer(regexp.MustCompile(":ProductName:.*"), ":ProductName: Maistra Service Mesh"),
			getRegexStringReplacer(regexp.MustCompile(":Install_BookName:.*"), ":Install_BookName: Installing Maistra"),
			getRegexStringReplacer(regexp.MustCompile(":RN_BookName:.*"), ":RN_BookName: Installing Maistra"),
			getRegexStringReplacer(regexp.MustCompile(":DocInfoProductName:.*"), ":DocInfoProductName: Maistra"),
		}...)
	} else if fileType == "doc" {
		fileDocsReplacers = append(docsReplacers, getHeaderReplacer(strings.Replace(title, "Service Mesh", "Maistra", -1), getDocID(string(body)), weight))
	}

	matches := []string{}
	if fileType == "doc" || fileType == "module" {
		bodyAsString := string(body)
		//convert doc as necessary to meet differences between Maistra and OSSM
		bodyAsString = convertDoc(bodyAsString, fileDocsReplacers)
		body = []byte(bodyAsString)
		matches, err = findDocReferences(bodyAsString, toMatch)
	}

	err = ioutil.WriteFile(filename, body, 0644)
	if err != nil {
		return []string{}, fmt.Errorf("failed to write file: %s", err)
	}

	return matches, err
}
