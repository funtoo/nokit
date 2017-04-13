# Copyright 1999-2010 Gentoo Foundation
# Copyright 2012 Adrien Dessemond <adrien.dessemond@funtoo.org>
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI="5"

inherit linux-mod eutils

DESCRIPTION="mhvtl kernel modules required for sys-block/mhvtl-utils (Virtual Tape Library)"
HOMEPAGE="http://sites.google.com/site/linuxvtl2"
SRC_URI="http://sites.google.com/site/linuxvtl2/mhvtl-2015-04-14.tgz -> mhvtl-1.5-3.tgz"
S=${WORKDIR}/mhvtl-1.5

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~sparc"

MODULE_NAMES="mhvtl(block:${S}/kernel:${S}/kernel)"

pkg_setup() {

	# MHVTL 1.x requires a kernel >= 2.6.19
	kernel_is ge 2 6 19 || die "Linux kernel >= 2.6.19 required"

	CONFIG_CHECK="~BLK_DEV_SR ~CHR_DEV_SG"
	check_extra_config
	BUILD_PARAMS="KDIR=${KV_DIR}"
	linux-mod_pkg_setup
}

src_prepare() {
	epatch "${FILESDIR}"/0001_make-gentoo-friendly-Makefiles.patch
}

src_compile() {

	linux-mod_src_compile || die "linux-mod_src_compile"
}

src_install() {
	linux-mod_src_install || die "Error: installing module failed!"
}

pkg_postinst() {
	linux-mod_pkg_postinst
}
