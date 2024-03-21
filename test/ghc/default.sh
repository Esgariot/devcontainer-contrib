#!/usr/bin/env bash

source dev-container-features-test-lib

check "'ghc' executable is present in PATH and works" ghc --version

reportResults
