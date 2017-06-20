# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

KMNAME="kdepim-runtime"
QT_MINIMAL="4.8.7"
EGIT_BRANCH="KDE/4.14"
inherit kde4-base

DESCRIPTION="KDE PIM runtime plugin collection"
COMMIT_ID="bb194cc299839cb00b808c9c5740169815ba9e39"
SRC_URI="https://quickgit.kde.org/?p=kdepim-runtime.git&a=snapshot&h=${COMMIT_ID}&fmt=tgz -> ${KMNAME}-${PV}.tar.gz"
S=${WORKDIR}/${PN}

KEYWORDS="amd64 x86"
IUSE="debug google"

RESTRICT="test"
# Would need test programs _testrunner and akonaditest from kdepimlibs, see bug 313233

DEPEND="
	$(add_kdeapps_dep kdepimlibs 'akonadi(+)' ${PV})
	dev-libs/boost:=
	dev-libs/libxml2:2
	dev-libs/libxslt
	kde-apps/akonadi:4
	x11-misc/shared-mime-info
	google? ( $(add_kdeapps_dep libkgapi '' 2.0) )
"
RDEPEND="${DEPEND}
	kde-frameworks/oxygen-icons:5
	!kde-misc/akonadi-google
"

pkg_setup() {
	if [[ $(gcc-major-version) -lt 5 ]] ; then
		ewarn "A GCC version older than 5 was detected. There may be trouble. See also Gentoo bug #595618"
	fi

	kde4-base_pkg_setup
}

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use_find_package google LibKGAPI2)
	)

	kde4-base_src_configure
}
