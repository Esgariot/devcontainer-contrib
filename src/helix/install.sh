#!/usr/bin/env -S bash -i

set -euo pipefail
. ./library_scripts.sh
ensure_nanolayer nanolayer_location "v0.4.45"

$nanolayer_location install apt-get git

$nanolayer_location \
    install \
    devcontainer-feature \
    "ghcr.io/devcontainers-contrib/features/gh-release:1.0.18" \
    --option repo='helix-editor/helix' --option binaryNames='hx' --option libName="runtime" --option version="$VERSION" --option releaseTagRegex "\d{2}\.(0[1-9]|1[1-2])(\.\d+)?" #YY.0M(.MICRO) version 

echo 'Done!'
