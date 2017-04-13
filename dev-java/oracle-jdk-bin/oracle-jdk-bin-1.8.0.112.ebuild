# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit eutils java-vm-2 prefix versionator

if [[ "$(get_version_component_range 4)" == 0 ]] ; then
	S_PV="$(get_version_component_range 1-3)"
else
	MY_PV_EXT="u$(get_version_component_range 4)"
	S_PV="$(get_version_component_range 1-4)"
fi

MY_PV="$(get_version_component_range 2)${MY_PV_EXT}"

AT_amd64="jdk-${MY_PV}-linux-x64.tar.gz"
#AT_arm="jdk-${MY_PV}-linux-arm-vfp-hflt.tar.gz"
AT_arm="jdk-8u111-linux-arm32-vfp-hflt.tar.gz"
AT_arm64="jdk-8u111-linux-arm64-vfp-hflt.tar.gz"
AT_x86="jdk-${MY_PV}-linux-i586.tar.gz"

DEMOS_amd64="jdk-${MY_PV}-linux-x64-demos.tar.gz"
#DEMOS_arm="jdk-${MY_PV}-linux-arm-vfp-hflt-demos.tar.gz"
DEMOS_arm="jdk-8u111-linux-arm32-vfp-hflt-demos.tar.gz"
DEMOS_arm64="jdk-8u111-linux-arm64-vfp-hflt-demos.tar.gz"
DEMOS_x86="jdk-${MY_PV}-linux-i586-demos.tar.gz"

JCE_DIR="UnlimitedJCEPolicyJDK8"
JCE_FILE="${JCE_DIR}.zip"

DESCRIPTION="Oracle's Java SE Development Kit"
HOMEPAGE="http://www.oracle.com/technetwork/java/javase/"
MIR_URI="mirror://funtoo/oracle-java"
SRC_URI="
	amd64? ( ${MIR_URI}/${AT_amd64} )
	arm? ( ${MIR_URI}/${AT_arm} )
	arm64? ( ${MIR_URI}/${AT_arm64} )
	x86? ( ${MIR_URI}/${AT_x86} )
	jce? ( ${MIR_URI}/${JCE_FILE} )"

LICENSE="Oracle-BCLA-JavaSE examples? ( BSD )"
SLOT="1.8"
KEYWORDS="*"
IUSE="alsa +awt cups derby doc examples +fontconfig javafx jce nsplugin pax_kernel selinux source"
REQUIRED_USE="javafx? ( alsa fontconfig )"

RESTRICT="mirror preserve-libs strip"
QA_PREBUILT="*"

RDEPEND="!x64-macos? (
		 awt? (
			x11-libs/libX11
			x11-libs/libXext
			x11-libs/libXi
			x11-libs/libXrender
			x11-libs/libXtst
		)
		javafx? (
			dev-libs/glib:2
			dev-libs/libxml2:2
			dev-libs/libxslt
			media-libs/freetype:2
			x11-libs/cairo
			x11-libs/gtk+:2
			x11-libs/libX11
			x11-libs/libXtst
			x11-libs/libXxf86vm
			x11-libs/pango
			virtual/opengl
		)
	)
	alsa? ( media-libs/alsa-lib )
	cups? ( net-print/cups )
	doc? ( dev-java/java-sdk-docs:${SLOT} )
	fontconfig? ( media-libs/fontconfig:1.0 )
	!prefix? ( sys-libs/glibc:* )
	selinux? ( sec-policy/selinux-java )"

# A PaX header isn't created by scanelf so depend on paxctl to avoid
# fallback marking. See bug #427642.
DEPEND="app-arch/zip
	jce? ( app-arch/unzip )
	examples? ( x64-macos? ( app-arch/unzip ) )
	pax_kernel? ( sys-apps/paxctl )"

S="${WORKDIR}/jdk"

src_unpack() {
	if use arm ; then
		# Special case for ARM soft VS hard float.
		if [[ ${CHOST} == *-hardfloat-* ]] ; then
			unpack $AT_arm
		#else
		#	unpack jdk-${MY_PV}-linux-arm-vfp-sflt.tar.gz
		fi
		use jce && unpack ${JCE_FILE}
	else
		default
	fi

	# Upstream is changing their versioning scheme every release around 1.8.0.*;
	# to stop having to change it over and over again, just wildcard match and
	# live a happy life instead of trying to get this new jdk1.8.0_05 to work.
	mv "${WORKDIR}"/jdk* "${S}" || die
}

src_prepare() {
	if use jce ; then
		mv "${WORKDIR}"/${JCE_DIR} jre/lib/security/ || die
	fi

	if [[ -n ${JAVA_PKG_STRICT} ]] ; then
		# Mark this binary early to run it now.
		pax-mark Cm ./bin/javap

		eqawarn "Ensure that this only calls trackJavaUsage(). If not, see bug #559936."
		eqawarn
		eqawarn "$(./bin/javap -J-Duser.home=${T} -c sun.misc.PostVMInitHook || die)"
	fi

	# Remove the hook that calls Oracle's evil usage tracker. Not just
	# because it's evil but because it breaks the sandbox during builds
	# and we can't find any other feasible way to disable it or make it
	# write somewhere else. See bug #559936 for details.
	zip -d jre/lib/rt.jar sun/misc/PostVMInitHook.class || die
}

src_install() {
	local dest="/opt/${P}"
	local ddest="${ED}${dest#/}"

	# Create files used as storage for system preferences.
	mkdir jre/.systemPrefs || die
	touch jre/.systemPrefs/.system.lock || die
	touch jre/.systemPrefs/.systemRootModFile || die

	if ! use alsa ; then
		rm -vf jre/lib/*/libjsoundalsa.* || die
	fi

	if ! use awt ; then
		rm -vf lib/*/lib*{[jx]awt,splashscreen}* \
		   bin/{javaws,policytool} || die
	fi

	if ! use javafx ; then
		rm -vf jre/lib/*/lib*{decora,fx,glass,prism}* \
		   jre/lib/*/libgstreamer-lite.* {,jre/}lib/{,ext/}*fx* \
		   bin/*javafx* bin/javapackager || die
	fi

	if ! use nsplugin ; then
		rm -vf jre/lib/*/libnpjp2.* || die
	else
		local nsplugin=$(echo jre/lib/*/libnpjp2.*)
	fi

	# Even though plugins linked against multiple ffmpeg versions are
	# provided, they generally lag behind what Gentoo has available.
	rm -vf jre/lib/*/libavplugin* || die

	dodoc COPYRIGHT
	dodir "${dest}"
	cp -pPR bin include jre lib man "${ddest}" || die

	if use derby ; then
		cp -pPR	db "${ddest}" || die
	fi

	if use examples && has ${ARCH} "${DEMOS_AVAILABLE[@]}" ; then
		cp -pPR demo sample "${ddest}" || die
	fi

	if use jce ; then
		dodir "${dest}"/jre/lib/security/strong-jce
		mv "${ddest}"/jre/lib/security/US_export_policy.jar \
			"${ddest}"/jre/lib/security/strong-jce || die
		mv "${ddest}"/jre/lib/security/local_policy.jar \
			"${ddest}"/jre/lib/security/strong-jce || die
		dosym "${dest}"/jre/lib/security/${JCE_DIR}/US_export_policy.jar \
			"${dest}"/jre/lib/security/US_export_policy.jar
		dosym "${dest}"/jre/lib/security/${JCE_DIR}/local_policy.jar \
			"${dest}"/jre/lib/security/local_policy.jar
	fi

	if use nsplugin ; then
		local nsplugin_link=${nsplugin##*/}
		nsplugin_link=${nsplugin_link/./-${PN}-${SLOT}.}
		dosym "${dest}/${nsplugin}" "/usr/$(get_libdir)/nsbrowser/plugins/${nsplugin_link}"
	fi

	if use source ; then
		cp -v src.zip "${ddest}" || die

		if use javafx ; then
			cp -v javafx-src.zip "${ddest}" || die
		fi
	fi

	if [[ -d jre/lib/desktop ]] ; then
		# Install desktop file for the Java Control Panel.
		# Using ${PN}-${SLOT} to prevent file collision with jre and or
		# other slots.  make_desktop_entry can't be used as ${P} would
		# end up in filename.
		newicon jre/lib/desktop/icons/hicolor/48x48/apps/sun-jcontrol.png \
			sun-jcontrol-${PN}-${SLOT}.png || die
		sed -e "s#Name=.*#Name=Java Control Panel for Oracle JDK ${SLOT}#" \
			-e "s#Exec=.*#Exec=/opt/${P}/jre/bin/jcontrol#" \
			-e "s#Icon=.*#Icon=sun-jcontrol-${PN}-${SLOT}#" \
			-e "s#Application;##" \
			-e "/Encoding/d" \
			jre/lib/desktop/applications/sun_java.desktop \
			> "${T}"/jcontrol-${PN}-${SLOT}.desktop || die
		domenu "${T}"/jcontrol-${PN}-${SLOT}.desktop
	fi

	# Prune all fontconfig files so libfontconfig will be used and only install
	# a Gentoo specific one if fontconfig is disabled.
	# http://docs.oracle.com/javase/8/docs/technotes/guides/intl/fontconfig.html
	rm "${ddest}"/jre/lib/fontconfig.*
	if ! use fontconfig ; then
		cp "${FILESDIR}"/fontconfig.Gentoo.properties "${T}"/fontconfig.properties || die
		eprefixify "${T}"/fontconfig.properties
		insinto "${dest}"/jre/lib/
		doins "${T}"/fontconfig.properties
	fi

	# This needs to be done before CDS - #215225
	java-vm_set-pax-markings "${ddest}"

	# see bug #207282
	einfo "Creating the Class Data Sharing archives"
	case ${ARCH} in
		arm|ia64)
			${ddest}/bin/java -client -Xshare:dump || die
			;;
		x86)
			${ddest}/bin/java -client -Xshare:dump || die
			# limit heap size for large memory on x86 #467518
			# this is a workaround and shouldn't be needed.
			${ddest}/bin/java -server -Xms64m -Xmx64m -Xshare:dump || die
			;;
		*)
			${ddest}/bin/java -server -Xshare:dump || die
			;;
	esac

	# Remove empty dirs we might have copied.
	find "${D}" -type d -empty -exec rmdir -v {} + || die

	if use x64-macos ; then
		# Fix miscellaneous install_name issues.
		pushd "${ddest}"/jre/lib > /dev/null || die
		local lib needed nlib npath
		for lib in decora_sse glass prism_{common,es2,sw} ; do
			lib=lib${lib}.dylib
			einfo "Fixing self-reference of ${lib}"
			install_name_tool \
				-id "${EPREFIX}${dest}/jre/lib/${lib}" \
				"${lib}"
		done
		popd > /dev/null

		# This is still jdk1{5,6}, even on Java 8, so don't change it
		# until you know different.
		for nlib in jdk1{5,6} ; do
			install_name_tool -change \
				/usr/lib/libgcc_s_ppc64.1.dylib \
				/usr/lib/libSystem.B.dylib \
				"${ddest}"/lib/visualvm/profiler/lib/deployed/${nlib}/mac/libprofilerinterface.jnilib
			install_name_tool -id \
				"${EPREFIX}${dest}"/lib/visualvm/profiler/lib/deployed/${nlib}/mac/libprofilerinterface.jnilib \
				"${ddest}"/lib/visualvm/profiler/lib/deployed/${nlib}/mac/libprofilerinterface.jnilib
		done
	fi

	set_java_env
	java-vm_revdep-mask
	java-vm_sandbox-predict /dev/random /proc/self/coredump_filter
}
