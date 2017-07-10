# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit eutils autotools readme.gentoo systemd

MY_P=${P/_beta/-beta}
DBV=20080531

DESCRIPTION="A simple utility to read the temperature of SMART capable hard drives"
HOMEPAGE="https://savannah.nongnu.org/projects/hddtemp/"
SRC_URI="http://download.savannah.gnu.org/releases/hddtemp/${MY_P}.tar.bz2 mirror://gentoo/hddtemp-${DBV}.db.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc sparc x86"
IUSE="nls selinux"

DEPEND=""
RDEPEND="selinux? ( sec-policy/selinux-hddtemp )"

S="${WORKDIR}/${MY_P}"

DISABLE_AUTOFORMATTING="yes"
DOC_CONTENTS="In order to update your hddtemp database, run:
emerge --config =${CATEGORY}/${PF}

If your hard drive is not recognized by hddtemp, please consider
submitting your HDD info for inclusion into the Gentoo hddtemp
database by filing a bug at https://bugs.gentoo.org/

If hddtemp complains but finds your HDD temperature sensor, use the
--quiet option to suppress the warning.
"

src_prepare() {
	epatch "${FILESDIR}"/${P}-satacmds.patch
	epatch "${FILESDIR}"/${P}-byteswap.patch
	epatch "${FILESDIR}"/${P}-execinfo.patch
	epatch "${FILESDIR}"/${P}-nls.patch
	epatch "${FILESDIR}"/${P}-iconv.patch
	epatch "${FILESDIR}"/${P}-dontwake.patch
	mv "${S}"/configure.{in,ac} || die
	AT_M4DIR="m4" eautoreconf
}

src_configure() {
	local myconf

	myconf="--with-db-path=/usr/share/hddtemp/hddtemp.db"
	# disabling nls breaks compiling
	use nls || myconf="--disable-nls ${myconf}"
	econf ${myconf}
}

src_install() {
	default
	dodoc README TODO ChangeLog

	insinto /usr/share/hddtemp
	newins "${WORKDIR}/hddtemp-${DBV}.db" hddtemp.db
	doins "${FILESDIR}"/hddgentoo.db

	update_db "${D}/usr/share/hddtemp/hddgentoo.db" "${D}/usr/share/hddtemp/hddtemp.db"
	newconfd "${FILESDIR}"/hddtemp-conf.d hddtemp
	newinitd "${FILESDIR}"/hddtemp-init hddtemp
	systemd_newunit "${FILESDIR}"/hddtemp.service-r1 "${PN}.service"
	systemd_install_serviced "${FILESDIR}"/hddtemp.service.conf

	readme.gentoo_create_doc
}

update_db() {
	local src=$1
	local dst=$2

	while read line ; do
		if [[ -z $(echo "${line}" | sed -re 's/(^#.*|^\w*$)//') ]]; then
			echo "${line}" >> "${dst}"
		fi

		id=$(echo "${line}" | grep -o '"[^"]*"')

		grep "${id}" "${dst}" 2>&1 >/dev/null || echo "${line}" >> "${dst}"
	done < "${src}"
}

pkg_config() {
	cd "${ROOT}"/usr/share/hddtemp || die

	einfo "Trying to download the latest hddtemp.db file"
	wget http://www.guzu.net/linux/hddtemp.db -O hddtemp.db \
		|| die "failed to download hddtemp.db"

	update_db "hddgentoo.db" "hddtemp.db"
}
