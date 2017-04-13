# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

# ebuild generated by hackport 0.3.6.9999
#hackport: flags: +newbase,+splitbase

CABAL_FEATURES="lib profile haddock hoogle hscolour"
inherit haskell-cabal

DESCRIPTION="Replaces/Enhances Text.Regex"
HOMEPAGE="http://hackage.haskell.org/package/regex-pcre"
SRC_URI="mirror://hackage/packages/archive/${PN}/${PV}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND=">=dev-haskell/regex-base-0.93:=[profile?]
	>=dev-lang/ghc-6.10.4:=
	dev-libs/libpcre
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-1.6.0.3
"

src_configure() {
	haskell-cabal_src_configure \
		--flag=newbase \
		--flag=splitbase
}
