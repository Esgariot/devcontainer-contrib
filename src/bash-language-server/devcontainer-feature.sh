pkgname="bash-language-server"
pkgver="5.0.0"
url="https://registry.npmjs.org/${pkgname}"
source=(
  "${url}/-/${pkgname}-${pkgver}.tgz"
  wrapper.sh
)
depends=(shellcheck)

_ensure_local_nvm() {
  source /usr/local/share/nvm/nvm.sh || [[ $? != 1 ]]
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
  nvm install --lts
}

package() {
  _ensure_local_nvm
  npm install -g --prefix "${pkgdir}/opt/${pkgname}" "${srcdir}/${pkgname}-${pkgver}.tgz"
  install -Dm 755 "${srcdir}/wrapper.sh" "${pkgdir}/usr/bin/${pkgname}"
}
