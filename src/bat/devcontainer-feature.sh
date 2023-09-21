pkgname="bat"
pkgver="0.23.0"
url="https://github.com/sharkdp/${pkgname}"

pkgver() {
    case "${VERSION:-"latest"}" in
        "latest") : "$(curl -Ls -o /dev/null -w %{url_effective} "${url}/releases/latest" | awk -F'/' '{print substr($NF,2)}')" ;;
        *)        : "${VERSION}" ;;
    esac
    echo "$_"
}

prepare() {
	:
}

build() {
	:
}

package() {
	nl install devcontainer-feature "ghcr.io/devcontainers-contrib/features/gh-release:1.0.18" --option repo='sharkdp/bat' --option binaryNames='bat' --option version="${pkgver}"
}
