#!/usr/bin/env bash

source dev-container-features-test-lib

check "'bat' executable is present in PATH and works" bat --version

reportResults

