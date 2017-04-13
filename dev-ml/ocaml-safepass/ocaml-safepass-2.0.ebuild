# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

OASIS_BUILD_DOCS=1

inherit oasis

DESCRIPTION="A library offering facilities for the safe storage of user passwords"
HOMEPAGE="http://ocaml-safepass.forge.ocamlcore.org/ https://github.com/darioteixeira/ocaml-safepass"
SRC_URI="https://github.com/darioteixeira/ocaml-safepass/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-2.1-with-linking-exception"
SLOT="0/${PV}"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

DOCS=( "README" "CHANGELOG" )
