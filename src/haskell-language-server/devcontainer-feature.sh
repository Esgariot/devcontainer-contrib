pkgname=haskell-language-server
pkgver="2.7.0.0"
url="https://github.com/haskell/${pkgname}"
depends=(libicu-dev libncurses-dev libgmp-dev zlib1g-dev patchelf)
source=()

pkgver() {
    case "${VERSION:-"latest"}" in
        "latest") : "$(curl -Ls -o /dev/null -w %{url_effective} "${url}/releases/latest" | awk -F'/' '{print $NF}')" ;;
        *)        : "${VERSION}" ;;
    esac
    echo "$_"
}

package() {
    local cabal_dir="${srcdir}/cabaldir"
    local ghc_ver="ghc-$(ghc --numeric-version)"
    CABAL_DIR="${cabal_dir}" ghcup compile hls --no-set --cabal-update --version "${pkgver}" --ghc "$(ghc --numeric-version)" --isolate "${pkgdir}/usr/bin/"
    find "${cabal_dir}/store/${ghc_ver}" -type f -name "*.so" -execdir install -Dm 644 "{}" "${pkgdir}/usr/lib/${ghc_ver}/lib/${pkgname}-${pkgver}/{}" \;
    patchelf --set-rpath "\$ORIGIN/../lib/${ghc_ver}/lib/x86_64-linux-${ghc_ver}:\$ORIGIN/../lib/${ghc_ver}/lib/${pkgname}-${pkgver}" "${pkgdir}/usr/bin/${pkgname}-$(ghc --numeric-version)"
}
