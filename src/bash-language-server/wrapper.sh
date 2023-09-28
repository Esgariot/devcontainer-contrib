#!/usr/bin/env bash

. /usr/local/share/nvm/nvm.sh || [[ $? != 1 ]] || exit 1

nvm use --lts >/dev/null
exec /opt/bash-language-server/bin/bash-language-server "$@"
