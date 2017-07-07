# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

: ${CMAKE_MAKEFILE_GENERATOR:=ninja}
PYTHON_COMPAT=( python2_7 )

# TODO: fix unnecessary dep on Python upstream
inherit cmake-utils flag-o-matic git-r3 python-any-r1 toolchain-funcs

DESCRIPTION="Compiler runtime library for clang (built-in part)"
HOMEPAGE="http://llvm.org/"
SRC_URI=""
EGIT_REPO_URI="http://llvm.org/git/compiler-rt.git
	https://github.com/llvm-mirror/compiler-rt.git"

LICENSE="|| ( UoI-NCSA MIT )"
SLOT="0/${PV%.*}"
KEYWORDS=""
IUSE="test"

RDEPEND="
	!<sys-devel/llvm-4.0"
DEPEND="${RDEPEND}
	~sys-devel/llvm-${PV}
	test? ( ~sys-devel/clang-${PV} )
	${PYTHON_DEPS}"

test_compiler() {
	$(tc-getCC) ${CFLAGS} ${LDFLAGS} "${@}" -o /dev/null -x c - \
		<<<'int main() { return 0; }' &>/dev/null
}

src_configure() {
	# pre-set since we need to pass it to cmake
	BUILD_DIR=${WORKDIR}/${P}_build

	if ! test_compiler; then
		local extra_flags=( -nodefaultlibs -lc )
		if test_compiler "${extra_flags[@]}"; then
			local -x LDFLAGS="${LDFLAGS} ${extra_flags[*]}"
			ewarn "${CC} seems to lack runtime, trying with ${extra_flags[*]}"
		fi
	fi

	local clang_version=4.0.0
	local libdir=$(get_libdir)
	local mycmakeargs=(
		# used to find cmake modules
		-DLLVM_LIBDIR_SUFFIX="${libdir#lib}"
		-DCOMPILER_RT_INSTALL_PATH="${EPREFIX}/usr/lib/clang/${clang_version}"
		# use a build dir structure consistent with install
		# this makes it possible to easily deploy test-friendly clang
		-DCOMPILER_RT_OUTPUT_DIR="${BUILD_DIR}/lib/clang/${clang_version}"

		# currently lit covers only sanitizer tests
		-DCOMPILER_RT_INCLUDE_TESTS=OFF
		-DCOMPILER_RT_BUILD_SANITIZERS=OFF
		-DCOMPILER_RT_BUILD_XRAY=OFF
	)

	cmake-utils_src_configure
}

run_tests_for_abi() {
	local ABI=${1}
}

src_test() {
	# prepare a test compiler
	local clang_version=4.0.0

	# copy clang over since resource_dir is located relatively to binary
	# therefore, we can put our new libraries in it
	mkdir -p "${BUILD_DIR}"/{bin,$(get_libdir),lib/clang/"${clang_version}"/include} || die
	cp "${EPREFIX}/usr/bin/clang" "${EPREFIX}/usr/bin/clang++" \
		"${BUILD_DIR}"/bin/ || die
	cp "${EPREFIX}/usr/lib/clang/${clang_version}/include"/*.h \
		"${BUILD_DIR}/lib/clang/${clang_version}/include/" || die

	# builtins are not converted to lit yet, so run them manually
	local tests=() f
	cd "${S}"/test/builtins/Unit || die
	while read -r -d '' f; do
		# ppc subdir is unmaintained and lacks proper guards
		# (and ppc builtins do not seem to be used anyway)
		[[ ${f} == ./ppc/* ]] && continue
		# these are special
		[[ ${f} == ./cpu_model_test.c ]] && continue
		[[ ${f} == ./gcc_personality_test.c ]] && continue
		# unsupported
		[[ ${f} == ./trampoline_setup_test.c ]] && continue
		tests+=( "${f%.c}" )
	done < <(find -name '*.c' -print0)

	{
		echo "check: ${tests[*]/#/check-}" &&
		echo ".PHONY: check ${tests[*]/#/check-}" &&
		for f in "${tests[@]}"; do
			echo "check-${f}: ${f}" &&
			echo "	${f}"
		done
	} > Makefile || die

	local ABI
	for ABI in $(get_all_abis); do
		# not supported at all at the moment
		[[ ${ABI} == x32 ]] && continue

		rm -f "${tests[@]}" || die

		einfo "Running tests for ABI=${ABI}"
		# use -k to run all tests even if some fail
		emake -k \
			CC="${BUILD_DIR}/bin/clang" \
			CFLAGS="$(get_abi_CFLAGS)" \
			CPPFLAGS='-I../../../lib/builtins' \
			LDFLAGS='-rtlib=compiler-rt' \
			LDLIBS='-lm'
	done
}

src_install() {
	cmake-utils_src_install

	# includes are mistakenly installed for all sanitizers and xray
	rm -rf "${ED}"usr/lib/clang/*/include || die
}
