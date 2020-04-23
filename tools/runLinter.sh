#!/bin/sh
set -e -x

#verify shell scripts
find . -name '*.sh' -print0 | xargs -0 -r shellcheck

#run documentation linting. See: https://github.com/errata-ai/vale
vale .
