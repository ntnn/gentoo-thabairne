# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3 cmake-utils

DESCRIPTION="A native Resource Abstraction Layer"
HOMEPAGE="https://github.com/puppetlabs/libral"
EGIT_REPO_URI="https://github.com/puppetlabs/libral"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-cpp/yaml-cpp
	dev-libs/boost
	>=sys-libs/glibc-2.12
	net-misc/curl
	app-admin/augeas
	>=dev-libs/leatherman-0.10.1
	dev-util/pkgconfig"
RDEPEND="${DEPEND}"

src_configure() {
	local mycmakeargs=(
		-DLIBRAL_DATA_DIR=/usr/share/libral
	)
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	cmake-utils_src_install

	# install data for ralph
	dodir /usr/share/libral
	mv "${S}/data" /usr/share/libral

	dodoc CHANGELOG.md CONTRIBUTING.md HACKING.md LICENSE README.md
}
