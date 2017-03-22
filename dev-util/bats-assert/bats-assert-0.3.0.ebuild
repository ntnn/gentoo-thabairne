# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Common assertions for Bats"
HOMEPAGE="https://github.com/ztombol/bats-assert"
SRC_URI="https://github.com/ztombol/bats-assert/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="CC0-1.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="app-shells/bash:0
		dev-util/bats[bats_lib_path]
		dev-util/bats-support"
RDEPEND="${DEPEND}"

src_test() {
	bats test
}

src_install() {
	insinto "/usr/lib/bats/${PN}"
	doins src/*

	dodoc CHANGELOG.md
	dodoc README.md
}
