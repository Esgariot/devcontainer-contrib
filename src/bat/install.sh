#!/usr/bin/env sh
set -eu

ASSET="$(gh release view --repo sharkdp/bat --json assets | jq --raw-output '.assets | .[] | .name | select(.|test("bat_[^_]+_amd64\\.deb"))')"

gh release download --pattern "${ASSET}" --repo 'sharkdp/bat'

dpkg -i "${ASSET}"