#!/usr/bin/env -S bash -i

set -euo pipefail
. ./library_scripts.sh
ensure_nanolayer nanolayer_location "v0.4.45"

$nanolayer_location install apt-get git
$nanolayer_location install apt-get curl
$nanolayer_location install apt-get jq

latest_ver="$(curl -sL https://api.github.com/repos/helix-editor/helix/releases/latest | jq -r ".tag_name")"
ver="${latest_ver}"
[[ "${VERSION}" =~ "latest" ]] || ver="${VERSION}"

pkg="helix-${ver}-x86_64-linux"

cd /tmp
curl -fLO "https://github.com/helix-editor/helix/releases/download/${ver}/${pkg}.tar.xz"

tar xJf "${pkg}.tar.xz"
rm -f "${pkg}.tar.xz"

# as in Arch's PKGBUILD for helix (https://gitlab.archlinux.org/archlinux/packaging/packages/helix)
sed -i "s|hx|helix|g" "${pkg}"/contrib/completion/hx.*

install -Dm 755 "${pkg}/hx" /usr/local/bin/helix
install -Dm 644 "${pkg}/runtime" /usr/local/lib/helix/runtime

install -Dm 644 "${pkg}/contrib/completion/hx.bash" "/usr/share/bash-completion/completions/helix"
install -Dm 644 "${pkg}/contrib/completion/hx.fish" "/usr/share/fish/vendor_completions.d/helix.fish"
install -Dm 644 "${pkg}/contrib/completion/hx.zsh" "/usr/share/zsh/site-functions/_helix"

