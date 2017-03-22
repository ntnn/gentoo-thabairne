# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3

DESCRIPTION="Supporting library for Bats test helpers"
HOMEPAGE="https://github.com/ztombol/bats-support"
EGIT_REPO_URI="https://github.com/ztombol/${PN}"

LICENSE="CC0-1.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="app-shells/bash:0
		dev-util/bats[bats_lib_path]"
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
