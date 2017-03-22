# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3

DESCRIPTION="Bash Automated Testing System"
HOMEPAGE="https://github.com/sstephenson/bats"
EGIT_REPO_URI="https://github.com/sstephenson/bats"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="app-shells/bash"
RDEPEND="${DEPEND}"

src_prepare() {
	epatch "${FILESDIR}/0001-Allow-sourcing-of-helper-files-from-BATS_LIB_PATH.patch"
}

src_install() {
	doman $(find man -type f -name 'bats*.?')

	exeinto /usr/libexec/bats
	doexe libexec/*

	dosym /usr/libexec/bats/bats /usr/bin/bats
}
