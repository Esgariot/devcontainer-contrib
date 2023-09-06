pkgname="emacs"
pkgver="29.1"
url="ftp://ftp.gnu.org/gnu/emacs"
source="${url}/emacs-${pkgver}.tar.gz"
depends=(
	build-essential
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
	mg
	curl
	autoconf
	pkg-config
)

pkgver() {
	case "${VERSION:-"latest"}" in
  	"latest") : "$(curl --list-only -SsfL "${url}" | perl -ne '$max=$1 if /emacs-(.*)\.tar\.gz/ && $1>$max; END {print "$max\n" }')" ;;
  	*) : "${VERSION}" ;;
	esac
	echo "$_"
}

prepare() {
	curl -LsfS -o "${pkgname}-${pkgver}.tar.gz" "${source}"

	if [ "${TREE-SITTER:-}" == "true" ]; then
		CONFIGUREFLAGS="--tree-sitter ${CONFIGUREFLAGS:-}"
	fi
	tar -xzf "${pkgname}-${pkgver}.tar.gz"
}

build() {
	cd "${pkgname}-${pkgver}"
	export CC=/usr/bin/gcc-10 CXX=/usr/bin/gcc-10
	./autogen.sh
	./configure "${CONFIGUREFLAGS:-}" --with-json --with-xml2 --without-x --without-sound \
    CFLAGS="-O2 -march=native -fomit-frame-pointer"
  make
}


package() {
	cd "${pkgname}-${pkgver}"
  make DESTDIR="${pkgdir}" install  
	find "${pkgdir}/usr/local/share/emacs/${pkgver}" -exec chown root:root {} \;
}
