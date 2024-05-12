#!/usr/bin/env -S bash -i

set -Eeuo pipefail
export DEBIAN_FRONTEND=noninteractive

script_dir=$(cd "$(dirname "${0}")" &>/dev/null && pwd -P)

. "${script_dir}/PKGBUILD"

metadir="/usr/local/share/devcontainer_feature/${pkgname}"
cachedir="/tmp/devcontainer_feature/cache/${pkgname}"

nl() { "${__install_nanolayer_cmd}" "$@"; }

__step_nanolayer() {
  . "${script_dir}/library_scripts.sh"
  ensure_nanolayer __install_nanolayer_cmd "${nlver:-"v0.5.6"}"
}

__step_install_deps() {
  nl install apt-get wget,gpg,sudo
  command -v makedeb >/dev/null || {
    wget -qO - 'https://proget.makedeb.org/debian-feeds/makedeb.pub' | gpg --dearmor --batch --yes -o /usr/share/keyrings/makedeb-archive-keyring.gpg
    echo 'deb [signed-by=/usr/share/keyrings/makedeb-archive-keyring.gpg arch=all] https://proget.makedeb.org/ makedeb main' | tee /etc/apt/sources.list.d/makedeb.list
  }
  nl install apt-get makedeb
}

__step_pkgver() {
  local tempsuffix
  case "$(uname -s)" in
    Darwin) tempsuffix='' ;;
    Linux) tempsuffix="$(mktemp)";;
  esac
  sed -i "${tempsuffix}" -e '1 s/^\s*pkgver=.*/pkgver="'"$(pkgver)"'"/; t' -e '1,// s//pkgver="'"$(pkgver)"'"/' "${script_dir}/PKGBUILD"
}

__step_add_user() {
  id devcontainer-feature &>/dev/null || {
    useradd -c "devcontainer-feature" -G sudo -M -r -s /sbin/nologin devcontainer-feature
    printf '%s ALL=(ALL:ALL) NOPASSWD: ALL\n' devcontainer-feature > /etc/sudoers.d/devcontainer-feature
  }
}

__step_install(){
  install -d -m 0775 -o root -g devcontainer-feature "${metadir}"
  install -d -m 0775 -o root -g devcontainer-feature "${cachedir}"
	install -D -t "${metadir}" "${script_dir}/PKGBUILD"
  cd "${metadir}"
}

__step_env() {
  if [[ ${_buildenv:-} ]]; then
    for e in "${_buildenv[@]}"; do
      [[ "${!e:-}" ]] || continue
      sed -i -e "1s;^;${e}=${!e}\n;" "${metadir}/PKGBUILD"
    done
  fi
  sha1sum "PKGBUILD" | head -c 40 > "PKGBUILD.sha1sum"
}

__step_wrapper() {
  local base="${pkgname}_${pkgver}-${pkgrel}_amd64"

  case "${INSTALL:-"default"}" in  
    default) {
			cat <<- EOF > "${metadir}/install.sh"
				#!/usr/bin/env sh
				echo "${pkgname} has been installed."
			EOF
			chmod 755 "${metadir}/install.sh"
			apt-get update
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
				if [ "\$(cat ${cachedir}/${base}.PKGBUILD.sha1sum >/dev/null 2>/dev/null)" = "$(cat PKGBUILD.sha1sum)" ]; then
					sudo dpkg -i "${cachedir}/${base}.deb" 
				else
					sudo apt-get update
					install -m644 "${metadir}/PKGBUILD" PKGBUILD
					env DEBIAN_FRONTEND=noninteractive makedeb PKGBUILD -sri --pass-env --no-confirm
					sudo install -Dm644 "${metadir}/PKGBUILD.sha1sum" "${cachedir}/${base}.PKGBUILD.sha1sum"
					sudo install -Dm644 "${base}.deb" "${cachedir}/${base}.deb"
				fi
			EOF
			chmod 755 "${metadir}/install.sh"
			install -Dm0440 <(printf '%s ALL=(devcontainer-feature) NOPASSWD: %s\n' ALL "${metadir}/install.sh") "/etc/sudoers.d/devcontainer-feature_${pkgname}"
		};;
	esac
}

install_sh() {
  while :; do
    case "${1-}" in
      --pkgver) __step_pkgver; exit;;
      -?*) echo "Unknown option: $1"; exit 1 ;;
      *) break ;;
    esac
    shift
  done

  __step_nanolayer
  __step_install_deps
  __step_add_user
  __step_install
  __step_env
  __step_wrapper
}

install_sh "$@"
