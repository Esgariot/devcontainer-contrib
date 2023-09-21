pkgname="gitui"
pkgver="0.24.3"
url="https://github.com/extrawurst/${pkgname}"
source="${url}/archive/v${pkgver}.tar.gz"
depends=(curl pkg-config build-essential)

pkgver() {
    case "${VERSION:-"latest"}" in
        "latest") : "$(curl -Ls -o /dev/null -w %{url_effective} "${url}/releases/latest" | awk -F'/' '{print substr($NF,2)}')" ;;
        *)        : "${VERSION}" ;;
    esac
    printf "$_"
}

prepare() {
    # ensure `rustup`
    command -v rustup 2>/dev/null || {
        nl install devcontainer-feature "ghcr.io/devcontainers/features/rust:1"
        source "/usr/local/cargo/env"
    }
    curl -Lsf -o "${pkgname}-v${pkgver}.tar.gz" "${source}"
    tar -xzf "${pkgname}-v${pkgver}.tar.gz"
}

build() {
    cd "${pkgname}-${pkgver}"
    export RUSTUP_TOOLCHAIN=stable
    export CARGO_TARGET_DIR=target
    export LIBGIT2_SYS_USE_PKG_CONFIG=1
    cargo build --locked --release
}

package() {
    cd "${pkgname}-${pkgver}"
    install -Dm0755 -t "$pkgdir/usr/bin/" "target/release/${pkgname}"
    install -Dm0644 -t "$pkgdir/usr/share/doc/$pkgname" {KEY_CONFIG,README,THEMES}.md
    install -Dm0644 -t "$pkgdir/usr/share/licenses/$pkgname" LICENSE.md
}
