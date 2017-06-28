# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python{2_7,3_{3,4,5}} )
DISTUTILS_SINGLE_IMPL=true

inherit distutils-r1

GITCOMMIT="f0891def54f1edb78a70006603d2b025236b830f"
DESCRIPTION='Python script to determine the RAM usage of a process'
LICENSE='LGPL-2.1'
SRC_URI="https://github.com/pixelb/ps_mem/archive/$GITCOMMIT.tar.gz"
SLOT='0'

KEYWORDS='~x86 ~amd64'

S="${WORKDIR}/$PN-$GITCOMMIT"

python_install_all() {
	doman "${PN}.1"

	distutils-r1_python_install_all
}
