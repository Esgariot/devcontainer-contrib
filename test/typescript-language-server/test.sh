#!/usr/bin/env bash

source dev-container-features-test-lib

check "'typescript-language-server' executable is present in PATH and works" typescript-language-server --version

reportResults

