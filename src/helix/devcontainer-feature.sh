pkgname="helix"
pkgver="23.10"
url="https://github.com/helix-editor/${pkgname}"
source=("${url}/releases/download/${pkgver}/${pkgname}-${pkgver}-source.tar.xz")
depends=(pkg-config xz-utils)

pkgver() {
    case "${VERSION:-"latest"}" in
        "latest") : "$(curl -Ls -o /dev/null -w %{url_effective} "${url}/releases/latest" | awk -F'/' '{print $NF}')" ;;
        *)        : "${VERSION}" ;;
    esac
    echo "$_"
}

prepare() {
    # ensure `rustup`
    if command -v rustup 2>/dev/null; then
        # assumes `rust` devcontainer feature has been installed
        source "/usr/local/cargo/env"
    else
        echo "rustup is required."
        exit 1
    fi

    tar -xvf "${pkgname}-${pkgver}-source.tar.xz"
    chown -R root .
}


build() {
    cargo build --locked --release
}


package() {
    install -Dm 755 "target/release/hx" "$pkgdir/usr/lib/$pkgname/hx"
    install -vdm 755 "$pkgdir/usr/bin"
    ln -sv /usr/lib/$pkgname/hx "$pkgdir/usr/bin/hx"
    install -Dm 644 README.md -t "$pkgdir/usr/share/doc/$pkgname"

    local runtime_dir="$pkgdir/usr/lib/$pkgname/runtime"
    mkdir -p "$runtime_dir/grammars"
    cp -r "runtime/queries" "$runtime_dir"
    cp -r "runtime/themes" "$runtime_dir"
    find "runtime/grammars" -type f -name '*.so' -exec install -Dm 755 {} -t "$runtime_dir/grammars" \;
    install -Dm 644 runtime/tutor -t "$runtime_dir"

    install -Dm 644 "contrib/completion/hx.bash" "$pkgdir/usr/share/bash-completion/completions/hx"
    install -Dm 644 "contrib/completion/hx.fish" "$pkgdir/usr/share/fish/vendor_completions.d/hx.fish"
    install -Dm 644 "contrib/completion/hx.zsh" "$pkgdir/usr/share/zsh/site-functions/_hx"
}
