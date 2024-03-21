#!/usr/bin/env bash

source dev-container-features-test-lib

check "'haskell-language-server-wrapper' executable is present in PATH and works" haskell-language-server-wrapper --version

reportResults
