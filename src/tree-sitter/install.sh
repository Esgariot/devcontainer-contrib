#!/usr/bin/env -S bash -i

set -Eeuo pipefail

script_dir=$(cd "$(dirname "${0}")" &>/dev/null && pwd -P)

nl() { "${__install_nanolayer_cmd}" "$@"; }

__step_install_nanolayer() {
  . "${script_dir}/library_scripts.sh"
  ensure_nanolayer __install_nanolayer_cmd "${nlver:-"v0.4.45"}"
}

__install_cleanup() {
  rm -rf "/tmp/devcontainer_feature"
}

__step_install_dirs(){
  trap '__install_cleanup' EXIT
  srcdir="/tmp/devcontainer_feature/srcdir/${pkgname}"
  pkgdir="/tmp/devcontainer_feature/pkgdir/${pkgname}"
  mkdir -p "${srcdir}" && cd "${srcdir}"
  mkdir -p "${pkgdir}"
}

__install_ensure_pkg() { dpkg-query -f='${Status:Want}' -W "${1}" || nl install apt-get "${1}"; }

__step_install_depends(){
  for d in "${depends[@]}"; do
    __install_ensure_pkg "${d}"
  done
}

__step_install_pkgver() {
  sed -i '0,/^\s*pkgver=/s/^\(s*\)pkgver=.*/\1pkgver="'"$(pkgver)"'"/' "${script_dir}/devcontainer-feature.sh"
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

install_sh() {
  while :; do
    case "${1-}" in
      --pkgver) __step_install_pkgver; exit;;
      -?*) echo "Unknown option: $1"; exit 1 ;;
      *) break ;;
    esac
    shift
  done
}

. "${script_dir}/devcontainer-feature.sh"
install_sh "$@"
__step_install_nanolayer
__step_install_dirs
__step_install_depends
__step_install_prepare
__step_install_build
__step_install_package
__step_install_copy
