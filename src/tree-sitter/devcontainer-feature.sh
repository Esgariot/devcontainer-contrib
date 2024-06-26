pkgname="tree-sitter"
pkgver="0.22.2"
url="https://github.com/tree-sitter/${pkgname}"
source=("${url}/archive/v${pkgver}.tar.gz")
depends=(build-essential curl)

pkgver() {
    case "${VERSION:-"latest"}" in
        "latest") : "$(curl -Ls -o /dev/null -w %{url_effective} "${url}/releases/latest" | awk -F'/' '{print substr($NF,2)}')" ;;
        *)        : "${VERSION}" ;;
    esac
    echo "$_"
}

prepare() {
  tar -xzf "${pkgname}-v${pkgver}.tar.gz"
}

build() {
  cd "${pkgname}-${pkgver}"
  make
}

package() {
  cd "${pkgname}-${pkgver}"
  make DESTDIR="${pkgdir}" PREFIX=/usr install
}
