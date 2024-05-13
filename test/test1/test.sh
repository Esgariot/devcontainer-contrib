#!/usr/bin/env bash

source dev-container-features-test-lib

# check "'ghc' executable is present in PATH and works" ghc --version

check  "print test1 file" cat /usr/share/test1
reportResults
