pkgname=haskell-language-server
pkgver="2.7.0.0"
url="https://github.com/haskell/${pkgname}"
depends=(libicu-dev libncurses-dev libgmp-dev zlib1g-dev)
source=()

pkgver() {
    case "${VERSION:-"latest"}" in
        "latest") : "$(curl -Ls -o /dev/null -w %{url_effective} "${url}/releases/latest" | awk -F'/' '{print $NF}')" ;;
        *)        : "${VERSION}" ;;
    esac
    echo "$_"
}

package() {
  ghcup compile hls --no-set --cabal-update --version "${pkgver}" --ghc "$(ghc --numeric-version)" --isolate "${pkgdir}/usr/bin/"
}
