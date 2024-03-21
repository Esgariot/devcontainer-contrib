pkgname="ghc"
pkgver="${VERSION}"
url="https://github.com/haskell/${pkgname}-hs"
source=()
depends=(build-essential curl)

package() {
  local option_bindist=()
  [[ "${BINDIST:-}" ]] && option_bindist+=("--url" "${BINDIST}")
  ghcup install "${pkgname}" "${option_bindist[@]}" "${pkgver}" --isolate "${pkgdir}/usr"
  find "${pkgdir}" -type f -exec sed -i "s@${pkgdir}@@g" {} \;
}

