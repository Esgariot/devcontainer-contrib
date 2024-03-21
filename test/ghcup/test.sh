#!/usr/bin/env bash

source dev-container-features-test-lib

check "'ghcup' executable is present in PATH and works" ghcup --version

reportResults
