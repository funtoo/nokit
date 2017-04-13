# Copyright 2016-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit eutils user versionator

DESCRIPTION="Anti-Spam SMTP Proxy written in Perl"
HOMEPAGE="https://${PN}.sourceforge.net/"
MY_PN=ASSP_$(replace_version_separator 3 '_')_install
SRC_URI="mirror://sourceforge/${PN}/${MY_PN}.zip"
LICENSE="GPL-2"
SLOT="0"

KEYWORDS="~amd64"

IUSE="ipv6 ldap sasl snmp spf srs ssl syslog"

DEPEND="app-arch/unzip
	${RDEPEND}"

#	dev-perl/Schedule-Cron
RDEPEND="dev-lang/perl[ithreads]
	dev-perl/Archive-Extract
	dev-perl/Archive-Zip
	dev-perl/BerkeleyDB
	dev-perl/Digest-SHA1
	dev-perl/Convert-Scalar
	dev-perl/Convert-TNEF
	dev-perl/Error
	dev-perl/Email-MIME
	dev-perl/Email-Send
	dev-perl/Email-Valid
	dev-perl/File-ReadBackwards
	dev-perl/IO-stringy
	dev-perl/Lingua-Identify
	dev-perl/Lingua-Stem-Snowball
	dev-perl/libwww-perl
	dev-perl/Mail-DKIM
	dev-perl/MIME-Types
	dev-perl/MIME-tools
	dev-perl/mime-construct
	dev-perl/NetAddr-IP
	dev-perl/Net-DNS
	dev-perl/Net-CIDR-Lite
	dev-perl/Net-IP
	dev-perl/Number-Compare
	dev-perl/Regexp-Optimizer
	dev-perl/Sys-CpuAffinity
	dev-perl/Sys-MemInfo
	dev-perl/Text-Glob
	dev-perl/Text-Unidecode
	dev-perl/Thread-State
	dev-perl/Unicode-LineBreak
	virtual/perl-Digest-MD5
	virtual/perl-IO-Compress
	virtual/perl-Time-HiRes
	virtual/perl-threads
	virtual/perl-threads-shared
	ipv6? ( dev-perl/IO-Socket-INET6 )
	sasl? ( dev-perl/Authen-SASL )
	snmp? ( dev-perl/Net-SNMP )
	spf? ( dev-perl/Mail-SPF )
	srs? ( dev-perl/Mail-SRS )
	ssl? ( dev-perl/IO-Socket-SSL
		dev-perl/Net-SMTP-SSL )
	syslog? ( virtual/perl-Sys-Syslog )
	ldap? ( dev-perl/perl-ldap )"

S=${WORKDIR}/${PN}

pkg_setup() {
	enewgroup assp
	enewuser assp -1 -1 /dev/null assp
}

src_prepare() {
	default
	local FILES="
		assp.pl
		assp_pop3.pl
		assp-monitor.pl
	"
	# just being safe
	for file in ${FILES}; do
		edos2unix ${file}
	done

	# portable changes via sed vs patch
	sed -i -e 's|file:files/|file:/etc/assp/|' \
		-e 's|-d "$base/dkim" or mkdir "$base/dkim",0755;||' \
		-e 's|-d "$base/docs" or mkdir "$base/docs,0755;"||' \
		-e 's|-d "$base/files" or mkdir "$base/files,0755;"||' \
		-e 's|-d "$base/language" or mkdir "$base/language",0755;||' \
		-e 's|-d "$base/lib" or mkdir "$base/lib", 0755;||' \
		-e 's|-d "$base/logs" or mkdir "$base/logs,0755;"||' \
		-e 's|-d "$base/notes" or mkdir "$base/notes",0755||' \
		-e 's|$base/certs/|/etc/assp/certs/|g' \
		-e 's|$base/files|/etc/assp|g' \
		-e 's|$base/images|/usr/share/assp/images|g' \
		-e 's|$base/reports/|/usr/share/assp/reports/|g' \
		-e 's|$base/lib|/usr/share/assp/lib|g' \
		-e 's|$base/notes/|/usr/share/assp/notes/|g' \
		-e "s|$base/docs/changelog|/usr/share/docs/assp-${PV}/changelog|g" \
		-e 's|$base/moduleLoadErrors|/var/log/assp/moduleLoadErrors|g' \
		-e 's|logs/maillog.txt|/var/log/assp/maillog.txt|' \
		-e 's|PID File'\'',40,textinput,'\''pid'\''|PID File'\'',40,textinput,'\''asspd.pid'\''|' \
		-e 's|Daemon\*\*'\'',0,checkbox,0|Daemon\*\*'\'',0,checkbox,1|' \
		-e 's|UID\*\*'\'',20,textinput,'\'''\''|UID\*\*'\'',20,textinput,'\''assp'\''|' \
		-e 's|GID\*\*'\'',20,textinput,'\'''\''|GID\*\*'\'',20,textinput,'\''assp'\''|' \
		-e 's|popFileEditor'\('\\'\''pb/pbdb\.\([^\.]*\)\.db\\'\'',|popFileEditor(\\'\''/var/lib/assp/pb/pbdb.\1.db\\'\'',|g' \
		-e 's|$base/assp.cfg|/etc/assp/assp.cfg|g' \
		-e 's|$base/$pidfile|/run/assp/asspd.pid|' \
		-e 's|mkdir "$base/$logdir",0700 if $logdir;||' \
		-e 's|mkdir "$base/$logdir",0700;||' \
		-e 's|$base/$logfile|$logfile|' \
		-e 's|$base/$logdir|$logdir|' \
		-e 's|"maillog.log"|"/var/log/assp/maillog.log"|' \
		-e 's|$base/$archivelogfile|$archivelogfile|' \
		-e 's|"$base/$file",$sub,"$this|"/etc/assp/$file",$sub,"$this|' \
		-e 's|"$base/$file",'\'''\'',"$this|"/etc/assp/$file",'\'''\'',"$this|' \
		-e 's|my $fil=$1; $fil="$base/$fil" if $fil!~/^\\Q$base\\E/i;|my $fil=$1;|' \
		-e 's|$fil="$base/$fil" if $fil!~/^\\Q$base\\E/i;|$fil="/etc/assp/$fil" if $fil!~/^\\/etc\\/assp\\/\|\\/var\\/lib\\/assp\\/\/i;|' \
		-e 's|$fil="$base/$fil" if $fil!~/^((\[a-z\]:)?\[\\/\\\\\]\|\\Q$base\\E)/;||' \
		-e 's|if ($fil !~ /^\\Q$base\\E/i) {|if ($fil !~ /^\\/usr\\/share\\/assp\\//i) {|' \
		-e 's|$fil="$base/$fil";|$fil="/usr/share/assp/$fil";|' \
		-e 's|Q$base\\E|Q\\/etc\\/assp\\/\\E|' \
		-e 's|$fil="$base/$fil"|$fil="/etc/assp/$fil"|' \
		-e 's|$base/$bf|/etc/assp/$bf|g' \
		-e 's|$base/ASSP_DEF_VARS|/usr/share/assp/lib/ASSP_DEF_VARS|g' \
		-e 's|$main::base . "/lib/AsspSelf|"/usr/share/assp/lib/AsspSelf|g' \
		-e 's|$main::base/lib/AsspSelf|/usr/share/assp/lib/AsspSelf|g' \
		-e 's|$base/$file.tmp|$file.tmp|g' \
		-e 's|$file.tmp","$base/$file"|$file.tmp","$file"|g' \
		-e 's|$base/version.txt|/etc/assp/version.txt|g' \
		-e 's|nointchk = '\''int'\''|nointchk = 1|g' \
		assp.pl || die

	sed -i -e 's|$base/images|/usr/share/assp/images|g' \
		-e 's|$base\E\/certs|/etc/assp/\E\/certs|g' \
		-e 's|$base/tmp|/var/lib/assp/tmp|g' \
		-e 's|$base/$file|/usr/share/assp/$file|g' \
		lib/ASSP_FC.pm || die

	# Disable force IPv4 DNS
	use ipv6 && sed -i -e 's|forceDNSv4:shared = 1|forceDNSv4:shared = 0|g' \
		assp.pl || die
	use ipv6 && sed -i '/sub set {/ a\
		$main::forceDNSv4 = 0;' lib/CorrectASSPcfg.pm || die

}

src_install() {
	# Configuration directory
	dodir /etc/assp/{certs,notes,optRe,reports}

	# Installs config files
	insinto /etc/assp
	doins {version,files/*}.txt

	insinto /etc/assp/dkim
	doins dkim/*.txt

	insinto /etc/assp/reports
	doins reports/*.txt

	fowners assp:assp /etc/assp -R
	fperms 770 /etc/assp /etc/assp/notes

	# Setup directories for mail to be stored for filter
	keepdir /var/lib/assp/{errors/notspam,errors/spam,notspam,okmail,resendmail,spam,virus,virusscan}

	# Logs directory
	keepdir /var/log/assp
	fowners assp:assp -R /var/log/assp
	fperms 770 /var/log/assp

	# Install the app
	exeinto /usr/share/assp
	doexe *.pl || die
	insinto /usr/share/assp
	doins -r {images,lib}/

	# ASSP downloads these files on start, creating for correct permissions
	touch lib/{ASSP_DEF_VARS.pm,rebuildspamdb.pm}

	# Lock down the files/data
	fowners assp:assp -R /usr/share/assp
	fperms 770 /usr/share/assp

	# Data storage
	fowners assp:assp -R /var/lib/assp
	fperms 770 /var/lib/assp

	# Install the init.d script to listen
	newinitd "${FILESDIR}/asspd.init" asspd

	dodoc {changelog_2.0.X,changelog_2.1.X,changelog_2.2.X,changelog_2.3.X,changelog,cmdqueue_example}.txt
	dodoc docs/*.{htm,png,txt}
	dohtml docs/*.htm
}

pkg_postinst() {
	elog
	elog "To configure ASSP, start /etc/init.d/asspd then point"
	elog "your browser to http://localhost:55555"
	elog "Username: root  Password: nospam4me (CHANGE ASAP!)"
	elog
	elog "File permissions have been set to use assp:assp"
	elog "with mode 770 on directories.  When you configure"
	elog "ASSP, make sure and use the user assp."
	elog
	elog "Don't change any path related options."
	elog
	elog "See the on-line docs for a complete tutorial."
	elog "http://assp.sourceforge.net/docs.html"
	elog
	elog "If upgrading, please update your old config to set both"
	elog "redre.txt and nodelay.txt path of /etc/assp.  There are"
	elog "also many new options that you should review."
	elog
}
