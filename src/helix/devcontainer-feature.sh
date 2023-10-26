pkgname="helix"
pkgver="23.10"
url="https://github.com/helix-editor/${pkgname}"
source=("${url}/archive/${pkgver}.tar.gz")
depends=(pkg-config)

pkgver() {
    case "${VERSION:-"latest"}" in
        "latest") : "$(curl -Ls -o /dev/null -w %{url_effective} "${url}/releases/latest" | awk -F'/' '{print $NF}')" ;;
        *)        : "${VERSION}" ;;
    esac
    echo "$_"
}

prepare() {
    semver() { echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }
    # ensure `rustup`
    if command -v rustup 2>/dev/null; then
        source "/usr/local/cargo/env"
    else
        echo "rustup is required."
        exit 1
    fi

    # check for newer git, because the one in packages is so old it can't interact with sr.ht
    # Required by custom build step for helix
    if command -v git 2>/dev/null && [ "$(semver "$(git --version | cut -d' ' -f3)")" -ge "$(semver "2.40.0")" ]; then
        :
    else
        echo "git >=2.40.0 is required"
        exit 1
    fi

    tar -xzf "${pkgver}.tar.gz"
}


build() {
    cd "${pkgname}-${pkgver}"
    cargo build --locked --release
}


package() {
    cd "${pkgname}-${pkgver}"
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
