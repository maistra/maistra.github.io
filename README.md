
# OpenShift Service Mesh

This repository contains documentation for the MVP (developer preview) release of OpenShift Service Mesh, based on the upstream Istio project.  This README provides information about this documentation repository.

Click here to read the [OpenShift Service Mesh MVP documentation](https://github.com/openshift-istio/istio-docs/blob/master/content/install-mvp.adoc) that was previously displayed at this location.  The linked document also includes information about associated sample applications (boosters) and tutorial scenarios(missions) released with the MVP.

## Getting Started

The OpenShift Service mesh documentation is written in [Asciidoc](http://asciidoctor.org/docs/asciidoc-syntax-quick-reference/).  This structure of this repository has been designed to work with both the upstream and downstream toolsets.  To generate the documentation, you should install the following tools:

* Upstream (community) - [Hugo](https://gohugo.io/)  
* Downstream (product) - [ccutils](https://pantheon.cee.redhat.com/#/help/ccutil)
* Both - [Asciidoctor](http://asciidoctor.org/docs/install-toolchain/) The downstream (product) documentation toolset requires asciidoc, and while the main content format for Hugo is markdown, Hugo also [supports asciidoc files](https://gohugo.io/content-management/formats/#additional-formats-through-external-helpers) by calling Asciidoctor.
* Text editor of your choice, for example the [Atom](https://atom.io/) text editor has several useful [packages](https://atom.io/packages) that make it easier to work with asciidoc and Hugo.

## Repository Structure
Hugo assumes that the same structure that organizes your source content is used to organize the rendered site. 


This repository uses the following directory structure:
```
├── [archetypes] - Can be used to define content, for example you can set default tags or categories and define types such as a post, tutorial or product here.  
├── [content] - Contains all the content files.
│   │   ├── .adoc (AsciiDoc topic files)
│   ├── Subfolders     
│   │   ├── .adoc (AsciiDoc topic files)
│   ├── DRAFTS - This directory is intended for topic stubs, topics that need to be written, and in-progress drafts. The Hugo config file is set to ignore this directory and its contents.  
│   │   ├── .adoc (AsciiDoc topic files)
├── [data] - Site data such a localization configurations go here.
├── [docs] - Files to build the downstream product manuals, which reference the content directory. 
│   ├── Doc-Installing-ServiceMesh
│   │   ├── master.adoc
│   │   ├── master-docinfo.xml
│   │   ├── buildGuide.sh (script to build this guide)
│   │   ├── topics -> ../topics/ (symlink to content directory)
│   ├── Doc-ServiceMesh-Release-Notes
│   │   ├── master.adoc
│   │   ├── master-docinfo.xml
│   │   ├── buildGuide.sh (script to build this guide)
│   │   ├── topics -> ../topics/ (symlink to content directory)
├── [layouts] -  Layouts for the Go html/template library which Hugo utilizes.  Note that themes override layouts.
├── [public] -  Generated output. (NOTE: This directory doesn't exist until you generate output.)
├── [scripts] - Contains scripts to automate the processes used to create and build documentation.
    └── buildGuides.sh (Builds the top-level Guides that live in the docs/ folder)
├── [static] - Any static files here will be compiled into the final website.
|   ├──  img - This directory contains all the images.  Hugo expects this directory name.
│   │  ├── .png
├── [themes] - This directory contains the theme for the site. (NOTE: Folder is EMPTY until you select a theme.)
├── config.toml - Main Hugo configuration file, used to define the websites title, language, URLs etc.
├── README.md (This file)
```

### Creating New Content

The documentation is written in asciidoc.  You can create new files from the command line, or by creating .adoc files in your favorite text editor.

To create a new file from the command line:
```
$ hugo new <section-name>/<new-content-lowercase>.adoc.
```
For example
```
$ hugo new product-overview.adoc
```
or
```
$ hugo new ./overviews/about.adoc
```

You can also create new .adoc files using a text editor.  Be sure to include the following metadata for the tools at the beginning of your files:

Hugo metadata
```
title: "Title Goes Here"
date: 2018-05-16T16:17:23-04:00
draft: true  or false
```
Modular documentation metadata - Provide an anchor in the format [id='anchor-name'] for every topic so that it can be identified by Asciidoctor when reused or cross-referenced. Give the anchor the same or similar name as the module heading, separated by dashes:
```
[id='anchor-name']
= Module Heading 
```
For example:
```
[id='product-overview']
= {Productname} Product Overview
```
For more information about writing modular documentation, see the [Modular Documentation Reference Guide](https://redhat-documentation.github.io/modular-docs/).

### To Build the Upstream Docs Web Site

The upstream docs use Hugo to generate the files for the web site.  

#### Starting the Hugo Server
Hugo provides its own webserver which builds and serves the site.  By default Hugo will also watch your files for any changes you make and automatically rebuild the site. It will then live reload any open browser pages and push the latest content to them.
	 	 	
To start the Hugo server run the following command:
````
$ hugo server
````
To start the Hugo server with draft files enabled run the following command:
```
$ hugo server -D
```
To start the Hugo server with live reload enabled, so that you can view changes immediately in your browser, run the following command:
```
$ hugo server --watch
```
To shut down the local server, use `CTRL + C`.

When your site is ready to ship, you can shut down your preview server and issue a command to build the actual pages of the site. In Hugo, that would be just `hugo`. Hugo puts the completed site in the `public` directory.

To generate the site output files:
```
$ hugo
```

To view the generated Hugo files, nagivate to the following directory:  `public/index.html`

For more information about Hugo commands, see the [Hugo Web site](https://gohugo.io/getting-started/usage/).

### To Build the Downstream Docs

The downstream docs use `ccutil` to generate the docs as part of the Docs-to-Drupal toolchain.

To build all of the books, open a terminal, navigate to the root directory of this repository, and type the following command (you may need to run it as `sudo`):
```
$ scripts/buildGuides.sh   
```
The script provides links to both asciidoctor and ccutil builds for each of the example books.

You can also build a single guide. Navigate to the folder of the manual you want to build and type the following command (you may need to run it as `sudo`):
```
$ ./buildGuide.sh
```

To view the generated output, nagivate to the following directory for a particular manual:`<title>/build/tmp/en-US/html-single/index.html`


## Submitting a Pull Request

You can close a GitHub issue from a Pull Request.  All you have to do is include the [special keyword syntax] (https://help.github.com/articles/closing-issues-using-keywords/) (for example, “fixes #5) in the body of your Pull Request.  When the pull request is merged into your repository's default branch, the corresponding issue is automatically closed.

Commit messages against Jira should start with the project name associated with the PR. If the PR is to address MAISTRA-123 then the commit message for the PR must start with "MAISTRA-123 " and then followed by the detailed commit message (no semi-column or dash between the Jira ID and text, no brackets... just a space).

