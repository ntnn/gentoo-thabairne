# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

MY_PN="Pale-Moon"

MOZ_FTP_URI="http://relmirror.palemoon.org/"
MOZ_LANGPACK_PREFIX="langpacks/${PV%%.*}.x/"
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
SRC_URI="https://github.com/MoonchildProductions/${MY_PN}/archive/${PV}_Release.tar.gz -> ${P}.tar.gz"

MOZCONFIG_OPTIONAL_GTK2ONLY="enabled"

inherit mozconfig-v6.52 mozlinguas-v2 gnome2-utils xdg-utils

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

	"${FILESDIR}/${PN}-27.5.1-gentoo_install_dirs.patch"
	"${FILESDIR}/${PN}-27.5.1-gentoo_preferences.patch"
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

S="${WORKDIR}/${MY_PN}-${PV}_Release"

BUILD_OBJ_DIR="${S}/${PN}_build"

pkg_setup() {
	moz_pkgsetup
}

src_unpack() {
	default
	mozlinguas-v2_src_unpack
}

src_prepare() {
	default

	# Ensure that our plugins dir is enabled as default
	sed -e "s:/usr/lib/mozilla/plugins:/usr/lib/nsbrowser/plugins:" \
		-i "${S}"/xpcom/io/nsAppFileLocationProvider.cpp \
		|| die "sed failed to replace plugin path for 32bit!"
	sed -e "s:/usr/lib64/mozilla/plugins:/usr/lib64/nsbrowser/plugins:" \
		-i "${S}"/xpcom/io/nsAppFileLocationProvider.cpp \
		|| die "sed failed to replace plugin path for 64bit!"
}

src_configure() {
	mozconfig_init

	mozconfig_config

	# in-tree cairo is incompatible with cairo-gtk3 toolkit
	# mozconfig_use_enable !gtk2 system-cairo

	mozconfig_use_enable sandbox
	mozconfig_use_enable content-sandbox
	echo "mk_add_options MOZ_OBJDIR=${BUILD_OBJ_DIR}" >> "${S}"/.mozconfig \
		|| die

	mozconfig_final
}

src_compile() {
	MOZ_MAKE_FLAGS="${MAKEOPTS}" \
		SHELL="${SHELL:-${EPREFIX%/}/bin/bash}" \
		emake -f client.mk realbuild
}

src_install() {
	cp "${FILESDIR}/gentoo-prefs.js" \
		"${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/all-gentoo.js" \
		|| die

	mozconfig_install_prefs \
		"${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/all-gentoo.js"

	MOZ_MAKE_FLAGS="${MAKEOPTS}" \
		SHELL="${SHELL:-${EPREFIX%/}/bin/bash}" \
		DESTDIR="${D}" \
		emake -f client.mk install

	mozlinguas-v2_src_install

	cd "${BUILD_OBJ_DIR}" || die

	# Install icons and .desktop for menu entry
	local size="" sizes="16 22 24 32 48 256"
	local icon_path="${S}/browser/branding/official"
	local icon="${PN}"
	local name="Palemoon"
	for size in ${sizes} ; do
		insinto "/usr/share/icons/hicolor/${size}x${size}/apps"
		newins "${icon_path}/default${size}.png" "${icon}.png"
	done
	# The 128x128 icon has a different name
	insinto "/usr/share/icons/hicolor/128x128/apps"
	newins "${icon_path}/mozicon128.png" "${icon}.png"
	# Install a 48x48 icon into /usr/share/pixmaps for legacy DEs
	newicon "${icon_path}/content/icon48.png" "${icon}.png"
	domenu "${icon_path}/${PN}.desktop"

	# Disable notification if USE="-startup-notification"
	if ! use startup-notification ; then
		sed -e '/^StartupNotify/s@true@false@' \
			-i "${ED}/usr/share/applications/${PN}.desktop" \
			|| die
	fi
}

pkg_postinst() {
	gnome2_icon_cache_update
	xdg_desktop_database_update

	einfo "Pale Moon only supports building with gcc4, which Gentoo does not support."
	einfo "Should you encounter any crashes, extensive resource usage etc.pp. open a"
	einfo "bug in the gentoo bug tracker before going to upstream."

	if ! use gtk2; then
		ewarn "Pale Moon does not work well with gtk3 at the moment. Should you experience"
		ewarn "issues please check if these also exist when building against gtk2."
	fi
}

pkg_postrm() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
}
