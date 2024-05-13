#!/usr/bin/env bash

source dev-container-features-test-lib

check "'cabal' executable is present in PATH and works" cabal --version

reportResults
