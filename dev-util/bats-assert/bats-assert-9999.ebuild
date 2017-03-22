# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3

DESCRIPTION="Common assertions for Bats"
HOMEPAGE="https://github.com/ztombol/bats-assert"
EGIT_REPO_URI="https://github.com/ztombol/bats-assert"

LICENSE="CC0-1.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="app-shells/bash
		>dev-util/bats-0.4.0
		dev-util/bats-support"
RDEPEND="${DEPEND}"

src_install() {
	insinto "/usr/lib/bats/${PN}"
	doins src/*
}
