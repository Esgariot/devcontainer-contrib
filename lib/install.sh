#!/usr/bin/env -S bash -i

set -Eeuo pipefail
export DEBIAN_FRONTEND=noninteractive

script_dir=$(cd "$(dirname "${0}")" &>/dev/null && pwd -P)

global_depends=(
  curl
  build-essential
  git
)

nl() { "${__install_nanolayer_cmd}" "$@"; }

__step_install_nanolayer() {
  . "${script_dir}/library_scripts.sh"
  ensure_nanolayer __install_nanolayer_cmd "${nlver:-"v0.4.45"}"
}

__step_install_dirs(){
  srcdir="/tmp/devcontainer_feature/srcdir/${pkgname}"
  pkgdir="/tmp/devcontainer_feature/pkgdir/${pkgname}"
  rm -rf "${srcdir}" "${pkgdir}" || :
  mkdir -p "${srcdir}" && cd "${srcdir}"
  mkdir -p "${pkgdir}"
}

__step_install_depends(){
  [[ "${depends:-}" ]] || depends=()
  depends+=("${global_depends[@]}")
  local missing_depends=()
  join_by() { local IFS="$1"; shift; echo "$*"; }
  for d in "${depends[@]}"; do
    dpkg-query -f='${Status:Want}' -W "${d}" || missing_depends+=("${d}")
  done
  nl install apt-get "$(join_by , "${missing_depends[@]}")"
}
__step_install_sources() {
  [[ ${sources:-} ]] && {
    for s in "${sources[@]}"; do
      cp "${script_dir}/${s}" "${srcdir}/"  
    done
  }
}

__step_install_pkgver() {
  sed -i "$(mktemp)" -e '1 s/^\s*pkgver=.*/pkgver="'"$(pkgver)"'"/; t' -e '1,// s//pkgver="'"$(pkgver)"'"/' "${script_dir}/devcontainer-feature.sh"
}

__step_install_prepare() {
  cd "${srcdir}"
  prepare
}

__step_install_build() {
  ldconfig
  cd "${srcdir}"
  declare -F build > /dev/null || return 0
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
__step_install_sources
__step_install_depends
__step_install_prepare
__step_install_build
__step_install_package
__step_install_copy
