# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cmake-utils gnome2-utils

if [[ "${PV}" == 9999 ]]; then
	inherit git-r3

	EGIT_REPO_URI="https://github.com/Gnurou/tagainijisho"
elif [[ "${PV}" == *_pre* ]]; then
	inherit vcs-snapshot

	TAGAINIJISHO_GIT_REVISION=""
fi
if [[ "${PV}" == 9999 || "${PV}" == *_pre* ]]; then
	JMDICT_DATE=""
	KANJIDIC2_DATE=""
	KANJIVG_VERSION="20160426"
fi

DESCRIPTION="Open-source Japanese dictionary and kanji lookup tool"
HOMEPAGE="https://www.tagaini.net/ https://github.com/Gnurou/tagainijisho"
if [[ "${PV}" == 9999 ]]; then
	SRC_URI=""
elif [[ "${PV}" == *_pre* ]]; then
	SRC_URI="https://github.com/Gnurou/${PN}/archive/${TAGAINIJISHO_GIT_REVISION}.tar.gz -> ${P}.tar.gz"
else
	SRC_URI="https://github.com/Gnurou/${PN}/releases/download/${PV}/${P}.tar.gz"
fi
if [[ "${PV}" == *_pre* ]]; then
	# Upstream: http://ftp.monash.edu.au/pub/nihongo/JMdict.gz
	SRC_URI+=" https://home.apache.org/~arfrever/distfiles/JMdict-${JMDICT_DATE}.gz"
fi
if [[ "${PV}" == *_pre* ]]; then
	# Upstream: http://www.edrdg.org/kanjidic/kanjidic2.xml.gz
	SRC_URI+=" https://home.apache.org/~arfrever/distfiles/kanjidic2-${KANJIDIC2_DATE}.xml.gz"
fi
if [[ "${PV}" == 9999 || "${PV}" == *_pre* ]]; then
	SRC_URI+=" https://github.com/KanjiVG/kanjivg/releases/download/r${KANJIVG_VERSION}/kanjivg-${KANJIVG_VERSION}.xml.gz"
fi

LICENSE="GPL-3+ public-domain"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND=">=dev-db/sqlite-3.12:3
	dev-qt/qtcore:5
	dev-qt/qtnetwork:5
	dev-qt/qtprintsupport:5
	dev-qt/qtwidgets:5"
DEPEND="${RDEPEND}
	dev-qt/linguist-tools:5"

pkg_langs=(ar cs de es fa fi fr hu id it nb nl pl pt ru sv th tr uk vi zh)
IUSE+=" ${pkg_langs[@]/#/l10n_}"
unset pkg_langs

src_unpack() {
	if [[ "${PV}" == 9999 ]]; then
		git-r3_src_unpack
	elif [[ "${PV}" == *_pre* ]]; then
		unpack ${P}.tar.gz
		mv tagainijisho-${TAGAINIJISHO_GIT_REVISION} ${P} || die
	else
		unpack ${P}.tar.gz
	fi

	if [[ "${PV}" == 9999 ]]; then
		# JMdict.gz and kanjidic2.xml.gz are updated once per day.

		local distdir="${PORTAGE_ACTUAL_DISTDIR:-${DISTDIR}}"
		local today="$(TZ="UTC" date --date=today "+%Y-%m-%d")"
		local yesterday="$(TZ="UTC" date --date=yesterday "+%Y-%m-%d")"

		if [[ -f ${distdir}/JMdict-${today}.gz && -s ${distdir}/JMdict-${today}.gz ]]; then
			# Use previously downloaded file from today.
			JMDICT_DATE="${today}"
		elif [[ -f ${distdir}/JMdict-${yesterday}.gz && -s ${distdir}/JMdict-${yesterday}.gz ]]; then
			# Use previously downloaded file from yesterday. File from today may still be nonexistent.
			JMDICT_DATE="${yesterday}"
		else
			# Download file from today or yesterday.
			wget http://ftp.monash.edu.au/pub/nihongo/JMdict.gz -O JMdict.gz || die
			JMDICT_DATE="$(gzip -cd JMdict.gz | grep -E "^<!-- JMdict created: [[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2} -->$" | sed -e "s/.*\([[:digit:]]\{4\}-[[:digit:]]\{2\}-[[:digit:]]\{2\}\).*/\1/")"
			if [[ ${JMDICT_DATE} != ${today} && ${JMDICT_DATE} != ${yesterday} ]]; then
				die "Unexpected date in JMdict.gz: '${JMDICT_DATE}'"
			fi
			(
				addwrite "${distdir}"
				mv JMdict.gz "${distdir}/JMdict-${JMDICT_DATE}.gz" || die
			)
		fi
		einfo "Date in JMdict.gz: '${JMDICT_DATE}'"

		if [[ -f ${distdir}/kanjidic2-${today}.xml.gz && -s ${distdir}/kanjidic2-${today}.xml.gz ]]; then
			# Use previously downloaded file from today.
			KANJIDIC2_DATE="${today}"
		elif [[ -f ${distdir}/kanjidic2-${yesterday}.xml.gz && -s ${distdir}/kanjidic2-${yesterday}.xml.gz ]]; then
			# Use previously downloaded file from yesterday. File from today may still be nonexistent.
			KANJIDIC2_DATE="${yesterday}"
		else
			# Download file from today or yesterday.
			wget http://www.edrdg.org/kanjidic/kanjidic2.xml.gz -O kanjidic2.xml.gz || die
			KANJIDIC2_DATE="$(gzip -cd kanjidic2.xml.gz | grep -E "^<date_of_creation>[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}</date_of_creation>$" | sed -e "s/.*\([[:digit:]]\{4\}-[[:digit:]]\{2\}-[[:digit:]]\{2\}\).*/\1/")"
			if [[ ${KANJIDIC2_DATE} != ${today} && ${KANJIDIC2_DATE} != ${yesterday} ]]; then
				die "Unexpected date in kanjidic2.xml.gz: '${KANJIDIC2_DATE}'"
			fi
			(
				addwrite "${distdir}"
				mv kanjidic2.xml.gz "${distdir}/kanjidic2-${KANJIDIC2_DATE}.xml.gz" || die
			)
		fi
		einfo "Date in kanjidic2.xml.gz: '${KANJIDIC2_DATE}'"

		mkdir "${S}/3rdparty" || die
		gzip -cd "${distdir}/JMdict-${JMDICT_DATE}.gz" > "${S}/3rdparty/JMdict" || die
		gzip -cd "${distdir}/kanjidic2-${KANJIDIC2_DATE}.xml.gz" > "${S}/3rdparty/kanjidic2.xml" || die
	elif [[ "${PV}" == *_pre* ]]; then
		mkdir "${S}/3rdparty" || die
		pushd "${S}/3rdparty" > /dev/null || die

		unpack JMdict-${JMDICT_DATE}.gz
		mv JMdict-${JMDICT_DATE} JMdict || die

		unpack kanjidic2-${KANJIDIC2_DATE}.xml.gz
		mv kanjidic2-${KANJIDIC2_DATE}.xml kanjidic2.xml || die

		popd > /dev/null || die
	fi

	if [[ "${PV}" == 9999 || "${PV}" == *_pre* ]]; then
		pushd "${S}/3rdparty" > /dev/null || die

		unpack kanjivg-${KANJIVG_VERSION}.xml.gz
		mv kanjivg-${KANJIVG_VERSION}.xml kanjivg.xml || die

		popd > /dev/null || die
	fi
}

src_configure() {
	# GUI linguae
	# en is not optional, and build fails if none other than en is set, so adding ja as non-optional too.
	local lang use_lang
	for lang in i18n/*.ts; do
		lang=${lang#i18n/tagainijisho_}
		lang=${lang%.ts}
		case ${lang} in
			fa_IR|fi_FI|pt_BR)
				# Use generic tags.
				use_lang=${lang%%_*}
				;;
			*)
				use_lang=${lang}
				;;
		esac

		if [[ ${lang} != en && ${lang} != ja ]] && ! use l10n_${use_lang}; then
			rm i18n/tagainijisho_${lang}.ts || die
		fi
	done

	# Dictionary linguae
	# en is not optional here either, but nothing special needs to be done.
	local dict_langs
	for lang in $(sed -e 's/;/ /g' -ne '/set(DICT_LANG ".*")/s/.*"\(.*\)".*/\1/p' CMakeLists.txt); do
		if use l10n_${lang}; then
			dict_langs+="${dict_langs:+;}${lang}"
		fi
	done

	local mycmakeargs=(
		-DDICT_LANG="${dict_langs}${dict_langs:-;}"
		-DEMBED_SQLITE=OFF
	)

	cmake-utils_src_configure
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
