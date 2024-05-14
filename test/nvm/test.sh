#!/usr/bin/env bash

source dev-container-features-test-lib

check "sourced 'nvm.sh' provides 'nvm'" source /usr/local/share/nvm/nvm.sh && nvm --version

reportResults
