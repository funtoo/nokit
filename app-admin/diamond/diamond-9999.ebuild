# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

if [[ ${PV} = 9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/python-diamond/Diamond.git"
	S=${WORKDIR}/diamond-${PV}
else
	SRC_URI="https://github.com/python-diamond/Diamond/archive/v${PV}.tar.gz -> python-diamond-${PV}.tar.gz"
	KEYWORDS="~amd64 ~x86 ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
	S=${WORKDIR}/Diamond-${PV}
fi

PYTHON_COMPAT=( python2_7 )

inherit distutils-r1 prefix

DESCRIPTION="Python daemon that collects and publishes system metrics"
HOMEPAGE="https://github.com/python-diamond/Diamond"

LICENSE="MIT"
SLOT="0"
IUSE="test mongo mysql snmp redis"

RDEPEND="dev-python/configobj
	dev-python/setproctitle
	mongo? ( dev-python/pymongo )
	mysql? ( dev-python/mysql-python )
	snmp? ( dev-python/pysnmp )
	redis? ( dev-python/redis-py )
	!kernel_linux? ( >=dev-python/psutil-3 )"
DEPEND="${RDEPEND}
	test? ( dev-python/mock )"

src_prepare() {
	# adjust for Prefix
	hprefixify bin/diamond*

	distutils-r1_src_prepare
}

python_test() {
	"${PYTHON}" ./test.py || die "Tests fail with ${PYTHON}"
}

python_install() {
	export VIRTUAL_ENV=1
	distutils-r1_python_install
	mv "${ED}"/usr/etc "${ED}"/ || die
	rm "${ED}"/etc/diamond/*.windows  # won't need these
	sed -i \
		-e '/pid_file =/s:/var/run:/run:' \
		"${ED}"/etc/diamond/diamond.conf.example || die
	hprefixify "${ED}"/etc/diamond/diamond.conf.example
}

src_install() {
	distutils-r1_src_install
	newinitd "${FILESDIR}"/${PN}.initd ${PN}
	newconfd "${FILESDIR}"/${PN}.confd ${PN}
	keepdir /var/log/diamond
}
