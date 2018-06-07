# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

MY_PN="UXP"
MY_PV="v${PV}"

DESCRIPTION="Unified XUL Platform Browser"
HOMEPAGE="https://www.basilisk-browser.org/"
SRC_URI="https://github.com/MoonchildProductions/${MY_PN}/archive/${MY_PV}.tar.gz -> ${P}.tar.gz"

MOZCONFIG_OPTIONAL_GTK2ONLY="enabled"

inherit mozconfig-v6.52 mozextension gnome2-utils xdg-utils

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

# cairo-gtk3 is incompatible with the in-tree cairo
IUSE="-official-branding sandbox content-sandbox devtools
	+shared-js alsa +system-icu gtk3 -jemalloc
	+system-cairo
"

REQUIRED_USE="content-sandbox? ( sandbox )
	gtk3? ( system-cairo )
	^^ ( alsa pulseaudio )
	^^ ( gtk2 gtk3 )
	official-branding? (
		!system-cairo
		!system-icu
		!system-jpeg
		!system-libevent
		!system-libvpx
		!system-sqlite
	)
"

PATCHES=(
	"${FILESDIR}/0001-CFLAGS-must-contain-fPIC-when-checking-the-linker.patch"

	"${FILESDIR}/${PN}-27.5.1-gentoo_install_dirs.patch"
	"${FILESDIR}/${PN}-27.5.1-gentoo_preferences.patch"
)

RDEPEND="
	app-arch/bzip2
	media-libs/libwebp
	>=sys-libs/glibc-2.23-r4
	sys-libs/zlib
	x11-libs/pango
	system-sqlite? ( dev-db/sqlite[secure-delete] )
"

DEPEND="${RDEPEND}
	dev-lang/python:2.7
	sys-devel/autoconf:2.1
	dev-lang/perl
"

S="${WORKDIR}/${MY_PN}-${PV}"

BUILD_OBJ_DIR="${S}/${PN}_build"

pkg_setup() {
	moz_pkgsetup
}

src_unpack() {
	default
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
	sed -i \
		-e '/intl-api/d' \
		-e '/system-harfbuzz/d' \
		-e '/MOZ_JEMALLOC4/d' \
		"${S}/.mozconfig"

	# Fix autotools not finding xargs
	echo "mk_add_options XARGS=/usr/bin/xargs" \
		>> "${S}/.mozconfig"

	# Defaults from Basilisk release builds
	mozconfig_annotate "Basilisk default" --enable-application=browser
	echo "mk_add_options MOZ_CO_PROJECT=browser" >> "${S}"/.mozconfig \
		|| die
	mozconfig_annotate "Basilisk default" --enable-release
	mozconfig_annotate "Basilisk default" --disable-updater
	# Enabling replace-malloc is not required as it only adds code to
	# replace the allocator at runtime
	mozconfig_annotate "Basilisk default" --disable-replace-malloc

	mozconfig_use_enable jemalloc

	mozconfig_use_enable official-branding

	mozconfig_use_enable devtools

	mozconfig_use_enable shared-js
	mozconfig_use_enable shared-js export-js

	mozconfig_use_enable alsa

	mozconfig_use_enable sandbox
	mozconfig_use_enable content-sandbox

	echo "mk_add_options MOZ_OBJDIR=${BUILD_OBJ_DIR}" >> "${S}"/.mozconfig \
		|| die

	mozconfig_final
}

src_compile() {
	MOZ_MAKE_FLAGS="${MAKEOPTS}" \
		SHELL="${SHELL:-${EPREFIX%/}/bin/bash}" \
		emake -f client.mk build
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

	for lang in ${MOZ_LANGS[@]}; do
		xlang=${lang}
		if has ${lang} "${MOZ_TOO_REGIONALIZED_FOR_L10N[@]}" ; then
			xlang=${lang%%-*}
		fi

		if use l10n_${xlang}; then
			local localedir="${WORKDIR}/${MY_LANGPACK_PN}-${MY_LANGPACK_PV}/${lang}"

			mv "${localedir}/browser/chrome/AB-CD" "${localedir}/browser/chrome/${xlang}" \
				|| die "Failed to move browser/chrome/{AB-CD => ${xlang}}"

			mkdir -p "${localedir}/chrome/${xlang}/locale" || die "Failed to create directory chrome/${xlang}/locale"
			mv "${localedir}/chrome/AB-CD/locale/AB-CD" "${localedir}/chrome/${xlang}/locale/${xlang}" \
				|| die "Failed to move chrome/{AB-CD => ${xlang}}/locale/{AB-CD => ${xlang}}"
			rm -rf "${localedir}/chrome/AB-CD" || die "Failed to remove chrome/AB-CD"

			xpi_install "${WORKDIR}/${MY_LANGPACK_PN}-${MY_LANGPACK_PV}/${lang}"
		fi
	done
}

pkg_postinst() {
	gnome2_icon_cache_update
	xdg_desktop_database_update

	einfo "DO NOT open an issue with upstream when encountering issues using Pale"
	einfo "Moon builds from this ebuild. Upstream DOES NOT support building with"
	einfo ">=gcc-5."
	einfo "Instead open an issue in the Gentoo bug tracker. The maintainers will"
	einfo "inspect the issue and coordinate with upstream if it isn't a >=gcc-5"
	einfo "related issue."

	if ! use gtk2; then
		ewarn "Basilisk does not work well with gtk3 at the moment. Should you"
		ewarn "experience issues please check if these also exist when building"
		ewarn "against gtk2."
	fi

	if ! use system-icu; then
		ewarn "Not building against system icu may cause connection errors when"
		ewarn "downloading extensions or loading pages."
	fi
}

pkg_postrm() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
}
