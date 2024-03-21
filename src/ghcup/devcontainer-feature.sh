pkgname="ghcup"
pkgver="0.1.22.0"
url="https://github.com/haskell/${pkgname}-hs"
source=("https://downloads.haskell.org/~${pkgname}/${pkgver}/x86_64-linux-${pkgname}-${pkgver}")
depends=(build-essential curl)

pkgver() {
  case "${VERSION:-"latest"}" in
    "latest") :  "$(curl -Ls -o /dev/null/ -w %{url_effective} "${url}/releases/latest" | awk -F'/' '{print substr($NF,2)}')" ;;
    *) : "${VERSION}" ;;
  esac
  echo "$_"
}

package() {
  install -Dm755 "x86_64-linux-${pkgname}-${pkgver}" "${pkgdir}/usr/bin/ghcup"
  _install_completion_script zsh "zsh/site-functions/_ghcup"
}

_install_completion_script() {
  install -Dm644 <("${pkgdir}/usr/bin/ghcup" "--${1}-completion-script" "/usr/bin/ghcup") "${pkgdir}/usr/share/${2}"
}
