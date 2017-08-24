# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

MOZ_FTP_URI="http://relmirror.palemoon.org/"
MOZ_LANGPACK_PREFIX="langpacks/27.x/"
MOZ_LANGS=(
	cs
	de
	en-GB
	es-AR
	es-ES
	es-MX
	fr
	hu
	it
	ko
	nl
	pl
	pt-BR
	pt-PT
	ru
	sv-SE
	tr
	zh-CN
)

DESCRIPTION="Open Source, Goanna-based web browser focusing on efficiency and ease of use."
HOMEPAGE="https://www.palemoon.org/"
SRC_URI="https://github.com/MoonchildProductions/Pale-Moon/archive/${PV}_Release.tar.gz -> ${P}.tar.gz"

MOZCONFIG_OPTIONAL_GTK2ONLY="available"

inherit mozconfig-v6.55 mozlinguas-v2

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

# cairo-gtk3 is incompatible with the in-tree cairo
IUSE="+official-branding sandbox content-sandbox +system-cairo"

REQUIRED_USE="content-sandbox? ( sandbox )
	!gtk2? ( system-cairo )
"

PATCHES=(
	"${FILESDIR}/0001-CFLAGS-must-contain-fPIC-when-checking-the-linker.patch"
	"${FILESDIR}/firefox-Include-sys-sysmacros.h-for-major-minor-when-availab.patch"
)

RDEPEND="
	>=sys-libs/glibc-2.23-r4
	x11-libs/pango
	system-sqlite? ( dev-db/sqlite[secure-delete] )
"

DEPEND="${RDEPEND}
	dev-lang/python:2.7
	sys-devel/autoconf:2.1
	dev-lang/perl
"

S="${WORKDIR}/Pale-Moon-${PV}_Release"

pkg_setup() {
	moz_pkgsetup
}

src_unpack() {
	default
	mozlinguas-v2_src_unpack
}

src_configure() {
	mozconfig_init

	mozconfig_config

	# in-tree cairo is incompatible with cairo-gtk3 toolkit
	# mozconfig_use_enable !gtk2 system-cairo

	mozconfig_use_enable sandbox
	mozconfig_use_enable content-sandbox

	mozconfig_final
}

src_compile() {
	MOZ_MAKE_FLAGS="${MAKEOPTS}" \
		SHELL="${SHELL:-${EPREFIX%/}/bin/bash}" \
		emake -f client.mk realbuild
}

src_install() {
	MOZ_MAKE_FLAGS="${MAKEOPTS}" \
		SHELL="${SHELL:-${EPREFIX%/}/bin/bash}" \
		DESTDIR="${D}" \
		emake -f client.mk install
}
