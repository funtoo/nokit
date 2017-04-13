# Distributed under the terms of the GNU General Public License v2

EAPI="5"

JAVA_PKG_IUSE="doc examples source"

inherit base java-pkg-2 linux-info versionator

RTM_NAME="JSS_${PV//./_}_RTM"

DESCRIPTION="Network Security Services for Java (JSS)"
HOMEPAGE="http://www.mozilla.org/projects/security/pki/jss/"
SRC_URI="ftp://ftp.mozilla.org/pub/mozilla.org/security/jss/releases/${RTM_NAME}/src/jss-${PV}.tar.bz2
	mirror://funtoo/jss-${PV}-fedora-ubuntu.tar.xz"
LICENSE="|| ( MPL-1.1 GPL-2 LGPL-2.1 )"
SLOT="3.4"
KEYWORDS="*"

CDEPEND=">=dev-libs/nspr-4.7 >=dev-libs/nss-3.12"

DEPEND=">=virtual/jdk-1.4
	app-arch/zip
	virtual/pkgconfig
	${CDEPEND}"

RDEPEND=">=virtual/jre-1.4 ${CDEPEND}"

S="${WORKDIR}/mozilla"

src_unpack() {
	unpack jss-${PV}.tar.bz2
	install -d ${WORKDIR}/patches || die
	tar xvf ${DISTDIR}/jss-${PV}-fedora-ubuntu.tar.xz -C ${WORKDIR}/patches || die
}

src_prepare() {
	cd ${S}
	for p in `cat ${FILESDIR}/${PV}-series`; do
		cat ${WORKDIR}/patches/$p | patch -p1 || die
	done
	cat ${FILESDIR}/jss-4.3.1-ldflags.patch | patch -p0 || die
	cat ${FILESDIR}/jss-4.2.5-use_pkg-config.patch | patch -p1 || die
}

src_compile() {
	export BUILD_OPT=1
	export USE_PKGCONFIG=1
	export NSS_PKGCONFIG=nss
	export NSPR_PKGCONFIG=nspr
	use amd64 && export USE_64=1
	# The Makefile is not thread-safe
	emake -j1 -C security/coreconf
	emake -j1 -C security/jss
	if use doc; then
		emake -j1 -C security/jss javadoc
	fi
}

# Investigate why this fails.
#
# cp: cannot stat ‘/var/tmp/portage/dev-java/jss-4.3-r1/work/mozilla/dist/Linux3.8_x86_64_glibc_PTH_64_OPT.OBJ//lib/*nssckbi*’: No such file or directory
# Failed to copy builtins library at security/jss/org/mozilla/jss/tests/all.pl line 453.
#
# There is indeed no nssckbi file, investigation needed if that file can be
# generated or whether we can remove the broken test; possibly inform upstream.
RESTRICT="test"

src_test() {
	BUILD_OPT=1 perl security/jss/org/mozilla/jss/tests/all.pl dist \
		"${S}"/dist/Linux*.OBJ/
}

src_install() {
	java-pkg_dojar dist/*.jar

	# Use this instead of the one in dist because it is a symlink
	# and doso handles symlinks by just symlinking to the original
	java-pkg_doso ./security/${PN}/lib/*/*.so

	use doc && java-pkg_dojavadoc dist/jssdoc
	use source && java-pkg_dosrc ./security/jss/org
	use examples && java-pkg_doexamples ./security/jss/samples
}
