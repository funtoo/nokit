# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit bash-completion-r1

DESCRIPTION="Gentoo-specific bash command-line completions (emerge, ebuild, equery, etc)"
HOMEPAGE="https://www.gentoo.org/"
SRC_URI="https://dev.gentoo.org/~mgorny/dist/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris"
IUSE=""

src_prepare() {
	# resolve openrc file collsions for bug 649144
	rm completions/rc-{service,status,update} || die
}

src_install() {
	emake DESTDIR="${D}" install \
		completionsdir="$(get_bashcompdir)" \
		helpersdir="$(get_bashhelpersdir)" \
		compatdir="${EPREFIX}/etc/bash_completion.d"
}