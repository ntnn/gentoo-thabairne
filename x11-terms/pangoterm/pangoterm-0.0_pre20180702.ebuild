# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

REV="607"

DESCRIPTION="A GTK/Pango-based terminal that uses libvterm to provide terminal emulation"
HOMEPAGE="http://www.leonerd.org.uk/code/pangoterm/"
SRC_URI="https://bazaar.launchpad.net/~leonerd/pangoterm/trunk/tarball/${REV} -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=">=dev-libs/libvterm-0.0_pre20151022"
RDEPEND="${DEPEND}
	dev-libs/glib:2
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:2
	x11-libs/pango
"

S="${WORKDIR}/~leonerd/${PN}/trunk"

DOCS=(
	pangoterm.cfg
)

src_install() {
	emake PREFIX="${EPREFIX}/usr" DESTDIR="${D}" install
	einstalldocs
}
