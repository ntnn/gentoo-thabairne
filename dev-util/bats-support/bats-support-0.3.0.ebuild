# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Supporting library for Bats test helpers"
HOMEPAGE="https://github.com/ztombol/bats-support"
SRC_URI="https://github.com/ztombol/bats-support/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="CC0-1.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="app-shells/bash
		>=dev-util/bats-0.4.0"
RDEPEND="${DEPEND}"

src_install() {
	insinto "/usr/lib/bats/${PN}"
	doins src/*
}
