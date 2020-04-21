
# OpenShift Service Mesh

This repository contains documentation for the community release of OpenShift Service Mesh, based on the upstream Istio project. This README provides information about this documentation repository. The site can be viewed at maistra.io.

## Getting Started

The OpenShift Service mesh documentation is written in [AsciiDoc](http://asciidoctor.org/docs/asciidoc-syntax-quick-reference/). This structure of this repository has been designed to work with both the upstream and downstream toolsets. To generate the documentation, you should install the following tools:

* [Hugo](https://gohugo.io/)
* [Asciidoctor](http://asciidoctor.org/docs/install-toolchain/). The downstream (product) documentation toolset requires AsciiDoc, and while the main content format for Hugo is markdown, Hugo also [supports AsciiDoc files](https://gohugo.io/content-management/formats/#additional-formats-through-external-helpers) by calling Asciidoctor.
* Text editor of your choice, for example the [Atom](https://atom.io/) text editor has several useful [packages](https://atom.io/packages) that make it easier to work with AsciiDoc and Hugo.

## Repository Structure
Hugo assumes that the same structure that organizes your source content is used to organize the rendered site.


This repository uses the following directory structure:
```
├── [archetypes] - Can be used to define content, for example you can set default tags or categories and define types such as a post, tutorial or product here.
├── [topics] - Contains all the content files.
|   ├── Blog -- This directory is used to render the Maistra blog, which is rendered on the fly from a collection of RSS feeds. 
|   ├── Docs -- This directory contains 
│   │   ├── .adoc (AsciiDoc topic files)
│   ├── DRAFTS - This directory is intended for topic stubs, topics that need to be written, and in-progress drafts. The Hugo config file is set to ignore this directory and its contents.
│   │   ├── .adoc (AsciiDoc topic files)
├── [data] - Site data such a localization configurations go here.
├── [layouts] -  Layouts for the Go html/template library which Hugo utilizes.  Note that themes override layouts.
├── [static] - Any static files here will be compiled into the final website.
|   ├──  img - This directory contains all the images.  Hugo expects this directory name.
│   │  ├── .png
├── [themes] - This directory contains the theme for the site.
├── config.toml - Main Hugo configuration file, used to define the websites title, language, URLs etc.
├── README.md (This file)
```

### Creating New Content

The documentation is written in AsciiDoc.  You can create new files from the command line, or by creating .adoc files in your favorite text editor.

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

You can also create new .adoc files using a text editor. 

### Docs Header
Content in the docs directory require the following headers to be populated in order to be listed in the docs:

```
---
title: "Bookinfo"
type: "document"
category: "Examples"
description: "Bookinfo is an example application that shows you how to set up and monitor a service mesh using Istio."
---
```

For more information about writing modular documentation, see the [Modular Documentation Reference Guide](https://redhat-documentation.github.io/modular-docs/).

### Previewing Changes Locally
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

For more information about Hugo commands, see the [Hugo Web site](https://gohugo.io/getting-started/usage/).

## Submitting a Pull Request

You can close a GitHub issue from a Pull Request.  All you have to do is include the [special keyword syntax] (https://help.github.com/articles/closing-issues-using-keywords/) (for example, “fixes #5) in the body of your Pull Request.  When the pull request is merged into your repository's default branch, the corresponding issue is automatically closed.

Commit messages against Jira should start with the project name associated with the PR. If the PR is to address MAISTRA-123 then the commit message for the PR must start with "MAISTRA-123 " and then followed by the detailed commit message (no semi-column or dash between the Jira ID and text, no brackets... just a space).

