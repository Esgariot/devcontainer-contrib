pkgname="emacs"
pkgver="29.2"
url="ftp://ftp.gnu.org/gnu/emacs"
source=("${url}/${pkgname}-${pkgver}.tar.gz")
depends=(
  libgnutls28-dev
  libncurses-dev
  texinfo
  libjansson4
  libjansson-dev
  libgccjit0
  libgccjit-10-dev
  gcc-10
  g++-10
  libxml2-dev
  shellcheck
  autoconf
  pkg-config
  zlib1g-dev
)

pkgver() {
  case "${VERSION:-"latest"}" in
    "latest") : "$(curl --list-only -SsfL "${url}/" | perl -ne '$max=$1 if /emacs-(.*)\.tar\.gz/ && $1>$max; END {print "$max\n" }')" ;;
    *) : "${VERSION}" ;;
  esac
  echo "$_"
}

prepare() {
  configure_flags=()
  if [ "${NATIVE_COMP:-}" == "true" ]; then
    configure_flags+=("--with-native-compilation=aot")
  fi

  if [ "${TREE_SITTER:-}" == "true" ]; then
    configure_flags+=("--tree-sitter")
  fi
  tar -xzf "${pkgname}-${pkgver}.tar.gz"
}

build() {
  cd "${pkgname}-${pkgver}"
  export CC=/usr/bin/gcc-10 CXX=/usr/bin/gcc-10
  ./autogen.sh
  ./configure "${configure_flags[@]}" --with-json --with-xml2 --without-x --without-sound \
    CFLAGS="-O2 -march=native -fomit-frame-pointer"
  make
}

package() {
  cd "${pkgname}-${pkgver}"
  make DESTDIR="${pkgdir}" install
  find "${pkgdir}/usr/local/share/emacs/${pkgver}" -exec chown root:root {} \;
}
