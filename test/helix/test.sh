#!/usr/bin/env bash

source dev-container-features-test-lib

check "'helix' executable is present in PATH and works" helix --version

reportResults

