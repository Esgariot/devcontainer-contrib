pkgname="cabal"
pkgver="3.10.3.0"
url="https://github.com/haskell/${pkgname}"
source=()
depends=(build-essential curl)

pkgver() {
    case "${VERSION:-"latest"}" in
        "latest") : "$(curl -Ls -o /dev/null -w %{url_effective} "${url}/releases/latest" | awk -F'/' '{sub(/^Cabal-v/, "",$NF); print $NF}')" ;;
        *)        : "${VERSION}" ;;
    esac
    echo "$_"
}

package() {
  ghcup install "${pkgname}" "${option_bindist[@]}" "${pkgver}" --isolate "${pkgdir}/usr/bin/"
}

