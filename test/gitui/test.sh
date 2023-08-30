#!/usr/bin/env bash

source dev-container-features-test-lib

check "'gitui' executable is present in PATH and works" gitui --version

reportResults
