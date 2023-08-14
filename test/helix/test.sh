#!/usr/bin/env bash

source dev-container-features-test-lib

check "'hx' executable is present in PATH and works" hx --version

reportResults

