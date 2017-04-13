# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

DESCRIPTION="Command-line interface to pasteme based pastebins"
HOMEPAGE="https://github.com/antematherian/mpaste"
SRC_URI="https://github.com/antematherian/mpaste/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ppc ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""


DEPEND=""
RDEPEND="=dev-lang/python-3*
	dev-python/requests
	dev-python/docopt"

src_install() {
	dobin ${PN}
}
