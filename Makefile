## Copyright 2019 Red Hat, Inc.
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.

.PHONY: lint
lint:
	./tools/runLinter.sh
.PHONY: check-links
check-links:
	./tools/checkLinks.sh
.PHONY: gen-install-options
gen-install-options:
	./tools/updateFields.sh vars.adoc
.PHONY: serve
serve: gen-install-options
	hugo serve
.PHONY: build
build: gen-install-options lint check-links
	hugo -D
.PHONY: verify-install-options
verify-install-options: gen-install-options
	./tools/check-git-status.sh
.PHONY: update-docs
update-docs:
	./tools/update-docs.sh
.PHONY: clean
clean:
	-rm -r out
	-rm -r public
docker-serve:
	docker run --rm -v $(shell pwd):/work -p 1313:1313 -it --entrypoint /bin/bash quay.io/maistra-dev/maistra-builder:2.0 -c 'make serve'
docker-lint:
	docker run --rm -v $(shell pwd):/work -p 1313:1313 -it --entrypoint /bin/bash quay.io/maistra-dev/maistra-builder:2.0 -c 'make lint'
docker-check-links:
	docker run --rm -v $(shell pwd):/work -p 1313:1313 -it --entrypoint /bin/bash quay.io/maistra-dev/maistra-builder:2.0 -c 'make check-links'
docker-build:
	docker run --rm -v $(shell pwd):/work -p 1313:1313 -it --entrypoint /bin/bash quay.io/maistra-dev/maistra-builder:2.0 -c 'make build'
