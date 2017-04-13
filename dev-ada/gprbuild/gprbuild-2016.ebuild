# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit toolchain-funcs multiprocessing

MYP=${PN}-gpl-${PV}

DESCRIPTION="Multi-Language Management"
HOMEPAGE="http://libre.adacore.com/"
SRC_URI="
	http://mirrors.cdn.adacore.com/art/57399662c7a447658e0affa8
		-> ${MYP}-src.tar.gz
	bootstrap? (
		http://mirrors.cdn.adacore.com/art/57399978c7a447658e0affc0
		-> xmlada-gpl-${PV}-src.tar.gz )"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="bootstrap +shared static static-pic"

DEPEND="dev-lang/gnat-gpl
	!bootstrap? ( dev-ada/xmlada )"
RDEPEND="${DEPEND}"

S="${WORKDIR}"/${MYP}-src

REQUIRED_USE="bootstrap? ( !shared !static !static-pic )"
PATCHES=( "${FILESDIR}"/${P}-gentoo.patch )

pkg_setup() {
	GCC=${ADA:-$(tc-getCC)}
	local base=$(basename ${GCC})
	GNATMAKE="${base/gcc/gnatmake}"
	if [[ ${base} != ${GCC} ]] ; then
		local path=$(dirname ${GCC})
		GNATMAKE="${path}/${GNATMAKE}"
	fi
	if [[ -z "$(type ${GNATMAKE} 2>/dev/null)" ]] ; then
		eerror "You need a gcc compiler that provides the Ada Compiler:"
		eerror "1) use gcc-config to select the right compiler or"
		eerror "2) set ADA=gcc-4.9.4 in make.conf"
		die "ada compiler not available"
	fi
}

src_configure() {
	if ! use bootstrap ; then
		default
	fi
}

bin_progs="gprbuild gprconfig gprclean gprinstall gprname gprls"
lib_progs="gprlib gprbind"

src_compile() {
	if use bootstrap; then
		local xmlada_src="../xmlada-gpl-${PV}-src"
		incflags="-Isrc -Igpr/src -I${xmlada_src}/sax -I${xmlada_src}/dom \
			-I${xmlada_src}/schema -I${xmlada_src}/unicode \
			-I${xmlada_src}/input_sources"
		$(tc-getCC) -c ${CFLAGS} src/gpr_imports.c -o gpr_imports.o
		for bin in ${bin_progs}; do
			${GNATMAKE} -j$(makeopts_jobs) ${incflags} $ADAFLAGS ${bin}-main \
				-o ${bin} -largs gpr_imports.o || die
		done
		for lib in $lib_progs; do
			${GNATMAKE} -j$(makeopts_jobs) ${incflags} ${lib} $ADAFLAGS \
				-largs gpr_imports.o || die
		done
	else
		emake PROCESSORS=$(makeopts_jobs) all
		for kind in shared static static-pic; do
			if use ${kind}; then
				emake PROCESSORS=$(makeopts_jobs) libgpr.build.${kind}
			fi
		done
	fi
}

src_install() {
	if use bootstrap; then
		dobin ${bin_progs}
		insinto /usr/share/gprconfig
		exeinto /usr/libexec/gprbuild
		doexe ${lib_progs}
		doins share/gprconfig/*.xml
		insinto /usr/share/gpr
		doins share/_default.gpr
	else
		default
		for kind in shared static static-pic; do
			if use ${kind}; then
				emake DESTDIR="${D}" libgpr.install.${kind}
			fi
		done
		mv "${D}"/usr/share/examples/${PN} "${D}"/usr/share/doc/${PF}/examples || die
		mv "${D}"/usr/share/doc/${PN}/* "${D}"/usr/share/doc/${PF} || die
		rmdir "${D}"/usr/share/doc/${PN} || die
	fi
	einstalldocs
}
