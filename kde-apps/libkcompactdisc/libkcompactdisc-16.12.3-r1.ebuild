# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

KDE_BLOCK_SLOT4="false"
inherit kde5

DESCRIPTION="Library for playing & ripping CDs"
LICENSE="GPL-2+ LGPL-2+"
KEYWORDS="amd64 x86"
IUSE="alsa"

RDEPEND="
	$(add_frameworks_dep kcoreaddons)
	$(add_frameworks_dep ki18n)
	$(add_frameworks_dep solid)
	$(add_qt_dep qtdbus)
	media-libs/phonon[qt5]
	alsa? ( media-libs/alsa-lib )
"
DEPEND="${RDEPEND}
	$(add_frameworks_dep kdelibs4support)
"

PATCHES=( "${FILESDIR}/${P}-no-alsa.patch" )

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use_find_package alsa Alsa)
	)
	kde5_src_configure
}
