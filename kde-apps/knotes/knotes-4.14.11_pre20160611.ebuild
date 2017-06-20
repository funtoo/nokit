# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

KDE_HANDBOOK="optional"
KMNAME="kdepim"
inherit kde4-meta

DESCRIPTION="Note taking application"
HOMEPAGE="https://www.kde.org/applications/utilities/knotes/"

KEYWORDS="amd64 x86"
IUSE="debug"

DEPEND="
	$(add_kdeapps_dep kdepim-common-libs)
	$(add_kdeapps_dep kdepimlibs)
"
RDEPEND="${DEPEND}"

KMCOMPILEONLY="
	noteshared/
"

KMEXTRACTONLY="
	akonadi_next/
	pimcommon/
"

KMLOADLIBS="kdepim-common-libs"
