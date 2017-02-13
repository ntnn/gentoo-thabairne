# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

EGO_PN=github.com/erning/gorun

inherit golang-vcs

DESCRIPTION="Shebang for go"
HOMEPAGE="https://github.com/erning/gorun"
SRC_URI="https://github.com/erning/gorun"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="dev-lang/go"
RDEPEND="${DEPEND}"

src_compile() {
	export GOPATH="$WORKDIR/$P"
	go build -v -o gorun "$EGO_PN" || die "Building gorun failed"
}

src_install() {
	dobin gorun
}
