#!/usr/bin/env bash

source dev-container-features-test-lib

check "'bash-language-server' executable is present in PATH and works" bash-language-server --version

reportResults

