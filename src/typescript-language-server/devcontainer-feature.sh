pkgname="typescript-language-server"
pkgver="4.0.0"
url="https://registry.npmjs.org/${pkgname}"
source=(
  "${url}/-/${pkgname}-${pkgver}.tgz"
  wrapper.sh
)

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
  local prefix="${pkgdir}/opt/${pkgname}"
  _ensure_local_nvm
  case "${TYPESCRIPT_VERSION:-"latest"}" in
    "latest") npm install -g --prefix "${prefix}" typescript ;;
    "none") : ;;
    *) npm install -g --prefix "${prefix}" "typescript@${TYPESCRIPT_VERSION}" ;;
  esac
  npm install -g --prefix "${prefix}" "${srcdir}/${pkgname}-${pkgver}.tgz"
  install -Dm 755 "${srcdir}/wrapper.sh" "${pkgdir}/usr/bin/${pkgname}"
}
