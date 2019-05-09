# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit multilib systemd user

DESCRIPTION="PuppetDB collects data generated by Puppet."
HOMEPAGE="http://docs.puppetlabs.com/puppetdb/"
SRC_URI="https://downloads.puppetlabs.com/${PN}/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
IUSE=""
# will need the same keywords as puppet
KEYWORDS="~amd64 ~x86"

RDEPEND+=">=virtual/jdk-1.7.0"
DEPEND+=""

pkg_setup() {
	enewgroup puppetdb
	enewuser puppetdb -1 -1 /opt/puppetlabs/server/data/puppetdb "puppetdb"
}

src_prepare() {
	sed -i 's/sysconfig/conf\.d/g' ext/redhat/puppetdb.service || die
	sed -i 's/sysconfig/conf\.d/g' ext/bin/puppetdb || die
	sed -i 's/sysconfig/conf\.d/g' install.sh || die
	sed -i 's/var\/run/run/g' ext/puppetdb.tmpfiles.conf || die
	sed -i 's/var\/run/run/g' install.sh || die
	default
}

src_compile() {
		einfo "not compiling"
}

src_install() {
	dodir /opt/puppetlabs/server/data/puppetdb
	insinto /opt/puppetlabs/server/apps/puppetdb
	insopts -m0744
	doins ext/ezbake-functions.sh
	insopts -m0644
	doins ext/ezbake.manifest
	doins puppetdb.jar
	insinto /etc/puppetlabs/puppetdb
	doins ext/config/logback.xml
	doins ext/config/bootstrap.cfg
	doins ext/config/request-logging.xml
	insinto /etc/puppetlabs/puppetdb/conf.d
	doins ext/config/conf.d/jetty.ini
	doins ext/config/conf.d/repl.ini
	doins ext/config/conf.d/database.ini
	doins ext/config/conf.d/config.ini
	insopts -m0755
	insinto /opt/puppetlabs/server/apps/puppetdb/scripts
	doins install.sh
	insinto /opt/puppetlabs/server/apps/puppetdb/cli/apps
	doins ext/cli/foreground
	doins ext/cli/ssl-setup
	doins ext/cli/config-migration
	doins ext/cli/foreground
	doins ext/cli/anonymize
	doins ext/cli/reload
	doins ext/cli/start
	doins ext/cli/stop
	insinto /opt/puppetlabs/server/apps/puppetdb/bin
	doins ext/bin/puppetdb
	insopts -m0644
	dodir /opt/puppetlabs/server/bin
	dosym ../apps/puppetdb/bin/puppetdb /opt/puppetlabs/server/bin/puppetdb
	dodir /opt/puppetlabs/bin
	dosym ../server/apps/puppetdb/bin/puppetdb /opt/puppetlabs/bin/puppetdb
	dosym ../../opt/puppetlabs/server/apps/puppetdb/bin/puppetdb /usr/bin/puppetdb
	# init type tasks
	newconfd ext/default puppetdb
	systemd_dounit ext/redhat/puppetdb.service
	systemd_newtmpfilesd ext/puppetdb.tmpfiles.conf puppetdb.conf
	newinitd "${FILESDIR}/puppetdb.initd" puppetdb
	# misc
	insinto /etc/logrotate.d
	newins ext/puppetdb.logrotate.conf puppetdb
	fowners -R puppetdb:puppetdb /opt/puppetlabs/server/data/puppetdb
	fperms -R 770 /opt/puppetlabs/server/data/puppetdb
}

pkg_postinst() {
	elog "to install please run '/opt/puppetlabs/server/bin/puppetdb ssl-setup'"
	elog
	elog "to upgrade please run '/opt/puppetlabs/server/bin/puppetdb config-migration'"
}
