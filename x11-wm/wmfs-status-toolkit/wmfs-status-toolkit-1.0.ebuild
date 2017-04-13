# Distributed under the terms of the GNU General Public License v2

EAPI="5"

DESCRIPTION="A C toolkit used to draw graphs and progressbars in the WMFS statusbar"
HOMEPAGE="https://freemobilega.power-heberg.com/armael/wmfs"
SRC_URI="https://freemobilega.power-heberg.com/armael/wmfs/wmfs-status-toolkit-1.0.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~*"
IUSE=""

RDEPEND="|| ( x11-wm/wmfs x11-wm/wmfs2 )"

DEPEND="${RDEPEND}"

S="${WORKDIR}/${PN}"

src_compile() {
	gcc -o "wmfs-status-graph" "graph.c" || die
	gcc -o "wmfs-status-progress" "progress.c" || die
	gcc -o "wmfs-status-gauge" "gauge.c" || die
}

src_install() {
	dobin wmfs-status-graph \
		wmfs-status-progress \
		wmfs-status-gauge
}
