# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3 epatch

DESCRIPTION="Bash Automated Testing System"
HOMEPAGE="https://github.com/sstephenson/bats"
EGIT_REPO_URI="https://github.com/sstephenson/bats"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+bats_lib_path"

DEPEND="app-shells/bash:0"
RDEPEND="${DEPEND}"

src_prepare() {
	if use bats_lib_path; then
		epatch "${FILESDIR}/${PV}/0001-Allow-sourcing-of-helper-files-from-BATS_LIB_PATH.patch"
		epatch "${FILESDIR}/${PV}/0002-Add-test-harness-for-various-library-loading-methods.patch"
		epatch "${FILESDIR}/${PV}/0003-Source-all-files-of-a-library-if-no-loading-file-exi.patch"
	fi
	default
}

src_test() {
	bin/bats --tap test
}

src_install() {
	doman $(find man -type f -name 'bats*.?')

	exeinto /usr/libexec/bats
	doexe libexec/*

	dosym /usr/libexec/bats/bats /usr/bin/bats
}
