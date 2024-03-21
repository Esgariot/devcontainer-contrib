pkgname="nvm"
pkgver="0.39.7"
url="https://github.com/nvm-sh/nvm"
source=("${url}/archive/v${pkgver}.tar.gz")
depends=(build-essential curl)

pkgver() {
  case "${VERSION:-"latest"}" in
    "latest") :  "$(curl -Ls -o /dev/null/ -w %{url_effective} "${url}/releases/latest" | awk -F'/' '{print substr($NF,2)}')" ;;
    *) : "${VERSION}" ;;
  esac
  echo "$_"
}

prepare() {
  tar -xzf "v${pkgver}.tar.gz"
}

package() {
  cd "${pkgname}-${pkgver}"
  install -Dm644 nvm.sh "$pkgdir/usr/local/share/${pkgname}/nvm.sh"
}
