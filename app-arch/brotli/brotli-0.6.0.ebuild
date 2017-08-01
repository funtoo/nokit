# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{4,5,6} pypy )
DISTUTILS_OPTIONAL="1"

inherit cmake-utils distutils-r1

DESCRIPTION="Generic-purpose lossless compression algorithm"
HOMEPAGE="https://github.com/google/brotli"
SRC_URI="https://github.com/google/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"

RDEPEND="python? ( ${PYTHON_DEPS} )"
DEPEND="${RDEPEND}"

IUSE="python test"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

LICENSE="MIT python? ( Apache-2.0 )"

DOCS=( README.md CONTRIBUTING.md )

PATCHES=( "${FILESDIR}"/${P}-no-rpath.patch )

src_prepare() {
	cmake-utils_src_prepare
	use python && distutils-r1_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=ON
		-DBUILD_TESTING="$(usex test)"
	)
	cmake-utils_src_configure
	use python && distutils-r1_src_configure
}

src_compile() {
	cmake-utils_src_compile
	use python && distutils-r1_src_compile
}

python_test(){
	esetup.py test || die
}

src_test() {
	cmake-utils_src_test
	use python && distutils-r1_src_test
}

src_install() {
	cmake-utils_src_install
	use python && distutils-r1_src_install
}
