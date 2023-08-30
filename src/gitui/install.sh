#!/usr/bin/env -S bash -i

set -Eeuo pipefail

(return 0 2>/dev/null) || {

  install_sh() {
    while :; do
      case "${1-}" in
        --pkgver) _pkgver; exit;;
        -?*) echo "Unknown option: $1"; exit 1 ;;
        *) break ;;
      esac
      shift
    done
  }

  _pkgver() {
    . ./devcontainer-feature.sh
    sed -i '0,/^\s*pkgver=/s/^\(s*\)pkgver=.*/\1pkgver="'"$(pkgver)"'"/' ./devcontainer-feature.sh
  }


  install_sh "$@"
}
. ./library_scripts.sh

. ./devcontainer-feature.sh

ensure_nanolayer __install_nanolayer_cmd "${nlver:-"v0.4.45"}"

srcdir="${HOME}/devcontainer_feature/${pkgname}"
pkgdir="${HOME}/.devcontainer_feature/tree/${pkgname}"
mkdir -p "${srcdir}" && cd "${srcdir}"
mkdir -p "${pkgdir}"

__install_cleanup() {
  rm -rf "~/devcontainer_feature"
}

trap '__install_cleanup' EXIT

nl() { "${__install_nanolayer_cmd}" "$@"; }

__install_ensure_pkg() { dpkg-query -f='${Status:Want}' -W "${1}" || nl install apt-get "${1}"; }

__step_install_depends(){
  for d in "${depends[@]}"; do
    __install_ensure_pkg "${d}"
  done
}

__step_install_prepare() {
  cd "${srcdir}"
  prepare
}


__step_install_build() {
  cd "${srcdir}"
  build
}

__step_install_package() {
  cd "${srcdir}"
  package
}

__step_install_copy() {
  (
    shopt -s dotglob
    shopt -s globstar
    export GLOBIGNORE=".:.."
    cd "${pkgdir}"
    for i in **/*; do
      [ ! -d  "${i}" ] && cp -P --parents "${i}" "/"
    done
  )
}

__step_install_depends
__step_install_prepare
__step_install_build
__step_install_package
__step_install_copy
