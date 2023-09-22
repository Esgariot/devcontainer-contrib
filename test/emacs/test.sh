#!/usr/bin/env bash

source dev-container-features-test-lib

check "'emacs' executable is present in PATH and works" emacs --version

reportResults
