# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

: ${CMAKE_MAKEFILE_GENERATOR:=ninja}
PYTHON_COMPAT=( python2_7 )

inherit cmake-utils git-r3

DESCRIPTION="The LLVM linker (link editor)"
HOMEPAGE="http://llvm.org/"
SRC_URI=""
EGIT_REPO_URI="http://llvm.org/git/lld.git
	https://github.com/llvm-mirror/lld.git"

LICENSE="UoI-NCSA"
SLOT="0"
KEYWORDS=""
IUSE="test"

RDEPEND="~sys-devel/llvm-${PV}"
DEPEND="${RDEPEND}
	test? ( dev-python/lit )"

# TODO: fix test suite to build stand-alone
RESTRICT="test"

src_unpack() {
	if use test; then
		# needed for patched gtest
		git-r3_fetch "http://llvm.org/git/llvm.git
			https://github.com/llvm-mirror/llvm.git"
	fi
	git-r3_fetch

	if use test; then
		git-r3_checkout http://llvm.org/git/llvm.git \
			"${WORKDIR}"/llvm
	fi
	git-r3_checkout
}

src_configure() {
	local libdir=$(get_libdir)
	local mycmakeargs=(
		-DLLVM_LIBDIR_SUFFIX="${libdir#lib}"
		# TODO: fix rpaths
		#-DBUILD_SHARED_LIBS=ON

		-DLLVM_INCLUDE_TESTS=$(usex test)
		# TODO: fix detecting pthread upstream in stand-alone build
		-DPTHREAD_LIB='-lpthread'
	)
	use test && mycmakeargs+=(
		-DLLVM_MAIN_SRC_DIR="${WORKDIR}/llvm"
		-DLIT_COMMAND="${EPREFIX}/usr/bin/lit"
	)

	cmake-utils_src_configure
}

src_test() {
	cmake-utils_src_make check-lld
}
