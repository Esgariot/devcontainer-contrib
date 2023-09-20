pkgname="bash-language-server"
pkgver="5.0.0"
url="https://registry.npmjs.org/${pkgname}"
source="${url}/-/${pkgname}-${pkgver}.tgz"
set -x
_ensure_local_nvm() {
  # lets be sure we are starting clean
  command -v nvm >/dev/null 2>&1
  nvm deactivate && nvm unload

  export NVM_DIR="${srcdir}/${pkgname}-core-${pkgver}/.nvm"
  # The init script returns 3 if version
  #   specified in ./.nvrc is not (yet) installed in $NVM_DIR
  #   but nvm itself still gets loaded ok
  source /usr/share/nvm/init-nvm.sh || [[ $? != 1 ]]
}

pkgver() {
  case "${VERSION:-"latest"}" in 
    "latest") : "$(curl -Ls "https://registry.npmjs.org/${pkgname}" | jq --raw-output '."dist-tags"."latest"')" ;;
    *)        : "${VERSION}" ;;
  esac
  echo "$_"
}

prepare() {
  _ensure_local_nvm
  nvm install "<FILL_NODE_VERSION>"
  curl -fsSL -o "${pkgname}-${pkgver}.tar.gz" "${source}"
}

package() {
  _ensure_local_nvm
  npm install -g --prefix "${pkgdir}/usr" "${srcdir}/${pkgname}-${pkgver}.tgz"
}
