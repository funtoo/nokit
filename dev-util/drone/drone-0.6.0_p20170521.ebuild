# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/drone/drone/..."
EGIT_COMMIT="3b5efe1ba16dd963e228937ce98ea1ac29fff390"
EGO_VENDOR=( "github.com/drone/drone-ui 76eae97423a0ab2194f82150eb47062580c28df7" )

inherit golang-build golang-vcs-snapshot user

ARCHIVE_URI="https://${EGO_PN%/*}/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
KEYWORDS="~amd64"

DESCRIPTION="A Continuous Delivery platform built on Docker, written in Go"
HOMEPAGE="https://github.com/drone/drone"
SRC_URI="${ARCHIVE_URI}
	${EGO_VENDOR_URI}"
LICENSE="Apache-2.0"
SLOT="0"
IUSE=""

DEPEND="dev-go/go-bindata
	dev-go/go-bindata-assetfs:="

pkg_setup() {
	enewgroup drone
	enewuser drone -1 -1 /var/lib/drone drone
}

src_compile() {
	pushd src || die
	GOPATH="${WORKDIR}/${P}:$(get_golibdir_gopath)"\
		go install -ldflags "-extldflags '-static' -X github.com/drone/drone/version.VersionDev=build.${EGIT_COMMIT:0:7}" github.com/drone/drone/drone || die
	popd || die
}

src_install() {
	dobin bin/*
	dodoc src/github.com/drone/drone/README.md
	keepdir /var/log/drone /var/lib/drone
	fowners -R drone:drone /var/log/drone /var/lib/drone
	newinitd "${FILESDIR}"/drone.initd drone
	newconfd "${FILESDIR}"/drone.confd drone
	newinitd "${FILESDIR}"/drone-agent.initd drone-agent
	newconfd "${FILESDIR}"/drone-agent.confd drone-agent
}
