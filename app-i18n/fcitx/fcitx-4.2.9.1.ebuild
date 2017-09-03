# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cmake-utils gnome2-utils multilib xdg

if [[ "${PV}" == "9999" ]]; then
	inherit git-r3

	EGIT_REPO_URI="https://github.com/fcitx/fcitx"
fi

DESCRIPTION="Fcitx (Flexible Context-aware Input Tool with eXtension) input method framework"
HOMEPAGE="https://fcitx-im.org/ https://github.com/fcitx/fcitx"
if [[ "${PV}" == "9999" ]]; then
	SRC_URI=""
else
	SRC_URI="https://download.fcitx-im.org/${PN}/${P}_dict.tar.xz"
fi

LICENSE="GPL-2+ LGPL-2+"
SLOT="0"
KEYWORDS="amd64 hppa ppc ppc64 x86"
IUSE="+X +autostart +cairo debug +enchant gtk2 gtk3 +introspection lua nls opencc +pango qt4 static-libs +table test +xml"
REQUIRED_USE="cairo? ( X ) pango? ( cairo ) qt4? ( X )"

RDEPEND="dev-libs/glib:2
	sys-apps/dbus
	virtual/libiconv
	virtual/libintl
	x11-libs/libxkbcommon
	X? (
		x11-libs/libX11
		x11-libs/libXfixes
		x11-libs/libXinerama
		x11-libs/libXrender
		xml? ( x11-libs/libxkbfile )
	)
	cairo? (
		x11-libs/cairo[X]
		x11-libs/libXext
		pango? ( x11-libs/pango )
		!pango? ( media-libs/fontconfig )
	)
	enchant? ( app-text/enchant )
	gtk2? ( x11-libs/gtk+:2 )
	gtk3? ( x11-libs/gtk+:3 )
	introspection? ( dev-libs/gobject-introspection )
	lua? ( dev-lang/lua:= )
	nls? ( sys-devel/gettext )
	opencc? ( app-i18n/opencc:= )
	qt4? (
		dev-qt/qtcore:4
		dev-qt/qtdbus:4
		dev-qt/qtgui:4
	)
	xml? (
		app-text/iso-codes
		dev-libs/libxml2
	)"
DEPEND="${RDEPEND}
	kde-frameworks/extra-cmake-modules:5
	virtual/pkgconfig"

DOCS=(AUTHORS ChangeLog THANKS)

PATCHES=(
	"${FILESDIR}/${P}-tray_icon.patch"
	"${FILESDIR}/${P}-qt-4_ucs4.patch"
)

src_prepare() {
	# https://github.com/fcitx/fcitx/issues/250
	sed \
		-e "/find_package(XkbFile REQUIRED)/i\\    if(ENABLE_X11)" \
		-e "/find_package(XkbFile REQUIRED)/s/^/    /" \
		-e "/find_package(XkbFile REQUIRED)/a\\    endif(ENABLE_X11)" \
		-i CMakeLists.txt

	# https://github.com/fcitx/fcitx/issues/342
	while IFS='' read -d $'\0' -r f ; do
		sed 's:^#!/bin/sh$:#!/usr/bin/env bash:' -i "${f}" || die
	done < <(find "${S}" -name '*.sh' -type f -print0)

	cmake-utils_src_prepare
	xdg_environment_reset
}

src_configure() {
	local mycmakeargs=(
		-DLIB_INSTALL_DIR="${EPREFIX}/usr/$(get_libdir)"
		-DSYSCONFDIR="${EPREFIX}/etc"
		-DENABLE_CAIRO=$(usex cairo)
		-DENABLE_DEBUG=$(usex debug)
		-DENABLE_ENCHANT=$(usex enchant)
		-DENABLE_GETTEXT=$(usex nls)
		-DENABLE_GIR=$(usex introspection)
		-DENABLE_GTK2_IM_MODULE=$(usex gtk2)
		-DENABLE_GTK3_IM_MODULE=$(usex gtk3)
		-DENABLE_LIBXML2=$(usex xml)
		-DENABLE_LUA=$(usex lua)
		-DENABLE_OPENCC=$(usex opencc)
		-DENABLE_PANGO=$(usex pango)
		-DENABLE_QT=$(usex qt4)
		-DENABLE_QT_GUI=$(usex qt4)
		-DENABLE_QT_IM_MODULE=$(usex qt4)
		-DENABLE_SNOOPER=$(if use gtk2 || use gtk3; then echo yes; else echo no; fi)
		-DENABLE_STATIC=$(usex static-libs)
		-DENABLE_TABLE=$(usex table)
		-DENABLE_TEST=$(usex test)
		-DENABLE_X11=$(usex X)
		-DENABLE_XDGAUTOSTART=$(usex autostart)
	)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	rm -r "${ED}usr/share/doc/${PN}"
}

pkg_preinst() {
	gnome2_icon_savelist
	xdg_pkg_preinst
}

pkg_postinst() {
	gnome2_icon_cache_update
	xdg_pkg_postinst
	use gtk2 && gnome2_query_immodules_gtk2
	use gtk3 && gnome2_query_immodules_gtk3
}

pkg_postrm() {
	gnome2_icon_cache_update
	xdg_pkg_postrm
	use gtk2 && gnome2_query_immodules_gtk2
	use gtk3 && gnome2_query_immodules_gtk3
}
