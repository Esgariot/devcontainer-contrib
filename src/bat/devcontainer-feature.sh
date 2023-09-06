pkgname="bat"
pkgver="_"

pkgver() {
	:
}

prepare() {
	:
}

build() {
	:
}

package() {
	nl install devcontainer-feature "ghcr.io/devcontainers-contrib/features/gh-release:1.0.18" --option repo='sharkdp/bat' --option binaryNames='bat' --option version="$VERSION"
}
