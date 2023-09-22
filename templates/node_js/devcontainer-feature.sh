pkgname="<FILL>"
pkgver=""
url="https://registry.npmjs.org/${pkgname}"
source=("${url}/-/${pkgname}-${pkgver}.tgz")

_ensure_local_nvm() {
  # ensure nvm
  if command -v nvm >/dev/null 2>&1 || [ -d /usr/local/share/nvm ]; then 
    :
  else
    {
      ( export UPDATE_RC="false"
        nl install devcontainer-feature "ghcr.io/devcontainers/features/node" \
            --option 'version=none' \
            --option 'nvmVersion=latest' \
            --option 'nodeGypDependencies=false'
      )
    }
  fi
  source /usr/local/share/nvm/nvm.sh || [[ $? != 1 ]]
}

pkgver() {
  case "${VERSION:-"latest"}" in 
    "latest") : "$(curl -Ls 'https://registry.npmjs.org/${pkgname}' | jq --raw-output '."dist-tags"."latest"')" ;;
    *)        : "${VERSION}" ;;
  esac
  echo "$_"
}

prepare() {
  _ensure_local_nvm
  nvm install "<FILL>"
  # ...
}

package() {
  _ensure_local_nvm
  npm install -g --prefix "${pkgdir}/opt/${pkgname}" "${srcdir}/${pkgname}-${pkgver}.tgz"
  install -Dm 755 "${srcdir}/wrapper.sh" "${pkgdir}/usr/bin/${pkgname}"
}
