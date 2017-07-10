# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit autotools-utils

DESCRIPTION="Hangul IMEngine for SCIM ported from imhangul"
HOMEPAGE="http://www.scim-im.org/"
SRC_URI="mirror://sourceforge/scim/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc x86"
IUSE="nls"

RDEPEND="|| ( >=app-i18n/scim-0.99.8 >=app-i18n/scim-cvs-0.99.8 )
	>=app-i18n/libhangul-0.0.4
	nls? ( virtual/libintl )"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	nls? ( sys-devel/gettext )"

PATCHES=(
	"${FILESDIR}/${PN}-0.3.2+gcc-4.3.patch"
	"${FILESDIR}/${PN}-0.3.2+gcc-4.7.patch"
	"${FILESDIR}/${PN}-0.4.0+gtk.patch" )

DOCS=(AUTHORS NEWS)

src_configure() {
	local myeconfargs=(
		--disable-skim-support
		$(use_enable nls)
	)
	autotools-utils_src_configure
}

src_install() {
	autotools-utils_src_install
	dodoc ChangeLog* README*
}

pkg_postinst() {
	elog
	elog "To use SCIM with both GTK2 and XIM, you should use the following"
	elog "in your user startup scripts such as .gnomerc or .xinitrc:"
	elog
	elog "LANG='your_language' scim -d"
	elog "export XMODIFIERS=@im=SCIM"
	elog
}
