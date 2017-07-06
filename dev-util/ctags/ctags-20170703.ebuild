# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools

COMMITHASH="0645b2c833e4ca956970cc96fab32a1b04c0c55c"

DESCRIPTION="Exuberant Ctags creates tags files for code browsing in editors"
HOMEPAGE="https://ctags.io/ https://github.com/universal-ctags/ctags"
SRC_URI="https://github.com/universal-ctags/ctags/archive/${COMMITHASH}.zip -> ${P}.zip"
S="${WORKDIR}/${PN}-${COMMITHASH}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="json xml yaml"

COMMON_DEPEND="
	json? ( dev-libs/jansson )
	xml? ( dev-libs/libxml2:2 )
	yaml? ( dev-libs/libyaml )
"
RDEPEND="
	${COMMON_DEPEND}
	app-eselect/eselect-ctags
"
DEPEND="
	${COMMON_DEPEND}
	dev-python/docutils
	virtual/pkgconfig
	app-arch/unzip
"

src_prepare() {
	default
	./misc/dist-test-cases > makefiles/test-cases.mak
	eautoreconf
}

src_configure() {
	econf \
		$(use_enable json) \
		$(use_enable xml) \
		$(use_enable yaml) \
		--disable-readlib \
		--disable-etags \
		--enable-tmpdir="${EPREFIX}"/tmp
}

src_install() {
	emake prefix="${ED}"/usr mandir="${ED}"/usr/share/man install

	# namepace collision with X/Emacs-provided /usr/bin/ctags -- we
	# rename ctags to exuberant-ctags (Mandrake does this also).
	mv "${ED}"/usr/bin/{ctags,exuberant-ctags} || die
	mv "${ED}"/usr/share/man/man1/{ctags,exuberant-ctags}.1 || die
}

pkg_postinst() {
	eselect ctags update

	if [[ -z "$REPLACING_VERSIONS" ]]; then
		elog "You can set the version to be started by /usr/bin/ctags through"
		elog "the ctags eselect module. \"man ctags.eselect\" for details."
	fi
}

pkg_postrm() {
	eselect ctags update
}
