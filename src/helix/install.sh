#!/usr/bin/env -S bash -i

set -euo pipefail
. ./library_scripts.sh
ensure_nanolayer na "v0.4.45"
set -x

ensure_pkg() { dpkg-query -f='${Status:Want}' -W "${1}" || $na install apt-get "${1}"; }

parse_version() {
    case "${1}" in
        "latest") : "$(curl -Ls -o /dev/null -w %{url_effective} "https://github.com/helix-editor/helix/releases/latest" | awk -F'/' '{print $NF}')" ;;
        *)        : "${VERSION}" ;;
    esac
    printf "$_"
}

command -v rustup 2>/dev/null || {
    $na install devcontainer-feature "ghcr.io/devcontainers/features/rust:1"
    source "/usr/local/cargo/env"
}

# Use git from PPA, because the one in packages is so old it can't interact with sr.ht
# Required by custom build step for helix
command -v git 2>/dev/null || {
    $na install devcontainer-feature "ghcr.io/devcontainers/features/git:1" --option 'version=latest'
}

ensure_pkg build-essential
ensure_pkg pkg-config
ensure_pkg curl

# adapted from https://gitlab.archlinux.org/archlinux/packaging/packages/helix
mkdir -p ~/clone/ && cd ~/clone
parsed_version="$(parse_version "${VERSION}")"
curl -Lsf -O "https://github.com/helix-editor/helix/archive/${parsed_version}.tar.gz"
tar -xzf "${parsed_version}.tar.gz"
cd "helix-${parsed_version}"
cargo build --locked --release


install -Dm 755 "target/release/hx" "/usr/lib/helix/hx"
ln -sv /usr/lib/helix/hx /usr/bin/hx
cp -r runtime /usr/lib/helix/

# completions
install -Dm 644 "contrib/completion/hx.bash" "/usr/share/bash-completion/completions/hx"
install -Dm 644 "contrib/completion/hx.fish" "/usr/share/fish/vendor_completions.d/hx.fish"
install -Dm 644 "contrib/completion/hx.zsh" "/usr/share/zsh/site-functions/_hx"

cd && rm -rf ~/clone