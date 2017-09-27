# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit prefix

DESCRIPTION="Chained EPREFIX utilities and wrappers"
HOMEPAGE="https://dev.gentoo.org/~haubi"
SRC_URI=""

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-linux ~sparc-solaris ~x86-solaris ~x86-winnt"
IUSE=""

DEPEND=""
RDEPEND="sys-devel/gcc-config"

src_unpack() {
	mkdir -p "${S}"
}

src_install() {
	cp "${FILESDIR}"/*.in "${T}"
	eprefixify "${T}"/*.in

	for x in "${T}"/*.in; do
		mv ${x} ${x%.in}
	done

	# install toolchain wrapper.
	wrapperdir=/usr/${CHOST}/gcc-bin/${CHOST}-prefix-chain-wrapper/${PV}
	wrappercfg=${CHOST}-prefix-chain-wrapper-${PV}

	exeinto $wrapperdir
	sed -i -e "s,@GENTOO_PORTAGE_CHOST@,${CHOST},g" "${T}"/prefix-chain-wrapper
	doexe "${T}"/prefix-chain-wrapper

	dosym $wrapperdir/prefix-chain-wrapper $wrapperdir/${CHOST}-gcc
	dosym $wrapperdir/prefix-chain-wrapper $wrapperdir/${CHOST}-g++
	dosym $wrapperdir/prefix-chain-wrapper $wrapperdir/${CHOST}-cpp
	dosym $wrapperdir/prefix-chain-wrapper $wrapperdir/${CHOST}-c++
	dosym $wrapperdir/prefix-chain-wrapper $wrapperdir/${CHOST}-windres

	dosym $wrapperdir/${CHOST}-gcc $wrapperdir/gcc
	dosym $wrapperdir/${CHOST}-g++ $wrapperdir/g++
	dosym $wrapperdir/${CHOST}-cpp $wrapperdir/cpp
	dosym $wrapperdir/${CHOST}-c++ $wrapperdir/c++
	dosym $wrapperdir/${CHOST}-windres $wrapperdir/windres

	# LDPATH is required to keep gcc-config happy :(
	cat > "${T}"/$wrappercfg <<EOF
GCC_PATH="${EPREFIX}/$wrapperdir"
LDPATH="${EPREFIX}/$wrapperdir"
EOF

	insinto /etc/env.d/gcc
	doins "${T}"/$wrappercfg

	# install startprefix script.
	exeinto /
	doexe "${T}"/startprefix
}