#!/usr/bin/env -S bash -i

set -Eeuo pipefail
set -x

MAKEDEB_VERSION="16.1.0-beta1"
UBUNTU_FLAVOR="$(grep -oP 'UBUNTU_CODENAME=\K\w+' /etc/os-release)"
export DEBIAN_FRONTEND=noninteractive
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

# install dependencies
apt-get update -qq
apt-get install -qq sudo curl

# install makedeb dependency
command -v makedeb || {
  makedebtmp="$(mktemp -d)"
  curl -sfL -o "${makedebtmp}/makedeb.deb" "https://github.com/makedeb/makedeb/releases/download/v${MAKEDEB_VERSION}/makedeb-beta_${MAKEDEB_VERSION}_amd64_${UBUNTU_FLAVOR}.deb"
  apt-get -f -qq install "${makedebtmp}/makedeb.deb"
}

# create user that will install the features
id devcontainer-feature &>/dev/null || {
  useradd -c "devcontainer-feature" -G sudo -M -r -s /sbin/nologin devcontainer-feature
  printf '%s ALL=(ALL:ALL) NOPASSWD: ALL\n' devcontainer-feature > /etc/sudoers.d/devcontainer-feature
}

# source PKGBUILD and set up variables and dirs for install locations
. "${script_dir}/PKGBUILD"
metadir="/usr/local/share/devcontainer_feature/${pkgname}"
cachedir="/tmp/devcontainer_feature/cache/${pkgname}"

install -d -m 0775 -o root -g devcontainer-feature "${metadir}"
install -d -m 0775 -o root -g devcontainer-feature "${cachedir}"
install -D -t "${metadir}" "${script_dir}/PKGBUILD"
cd "${metadir}"

# fill out correct pkgver in PKGBUILD. Update locally too.
pkgver="$(pkgver)"
sed -i "$(mktemp)" -e '1 s/^\s*pkgver=.*/pkgver="'"${pkgver}"'"/; t' -e '1,// s//pkgver="'"${pkgver}"'"/' "${metadir}/PKGBUILD"

# NOTE: shadow pkgver() so makedeb doesn't treat it as devel package (buggy)
cat <<- EOF >> "${metadir}/PKGBUILD"

pkgver() {
	echo "\${pkgver}"
}
EOF

if [[ ${_buildenv:-} ]]; then
  for e in "${_buildenv[@]}"; do
    [[ "${!e:-}" ]] || continue
    sed -i -e "1s;^;${e}=${!e}\n;" "${metadir}/PKGBUILD"
  done
fi
printf '%s\n' "$(sha1sum "PKGBUILD" | head -c 40)" > "${metadir}/PKGBUILD.sha1sum"

# create wrapper script
BASE_NAME="${pkgname}_${pkgver}-${pkgrel}_amd64"
case "${INSTALL:-"default"}" in
  default) {
		cat <<- EOF > "${metadir}/install.sh"
			#!/usr/bin/env sh
			
			echo "${pkgname} has been installed."
		EOF
		chmod 755 "${metadir}/install.sh"
		sudo -u devcontainer-feature env DEBIAN_FRONTEND=noninteractive makedeb "${metadir}/PKGBUILD" -sri --pass-env --no-confirm
	};;
	deferred) {
		cat <<- EOF > "${metadir}/install.sh"
			#!/usr/bin/env sh
			set -eu
			if [ "\$(id -u)" = "\$(id -u devcontainer-feature)" ]; then
				:
			else
				echo "re-running as user=devcontainer-feature"
				exec sudo -u devcontainer-feature "\$0" "\$@"
			fi
			stagedir="/tmp/devcontainer_feature/stage/${pkgname}"
			sudo install -dm0775 -o root -g devcontainer-feature "\${stagedir}"
			cd "\${stagedir}"
			if [ "\$(cat ${cachedir}/${BASE_NAME}.PKGBUILD.sha1sum 2>/dev/null)" = "$(cat PKGBUILD.sha1sum)" ]; then
				echo "Found matching deb package in cache. Installing..."
				sudo apt-get install -qq "${cachedir}/${BASE_NAME}.deb"
			else
				echo "Installing..."
				sudo apt-get update
				install -m644 "${metadir}/PKGBUILD" PKGBUILD
				env DEBIAN_FRONTEND=noninteractive makedeb PKGBUILD -sri --pass-env --no-confirm
				sudo install -Dm644 "${metadir}/PKGBUILD.sha1sum" "${cachedir}/${BASE_NAME}.PKGBUILD.sha1sum"
				sudo install -Dm644 "${BASE_NAME}.deb" "${cachedir}/${BASE_NAME}.deb"
			fi
		EOF
		chmod 755 "${metadir}/install.sh"
		install -Dm0440 <(printf '%s ALL=(devcontainer-feature) NOPASSWD: %s\n' ALL "${metadir}/install.sh") "/etc/sudoers.d/devcontainer-feature_${pkgname}"
	};;
esac

