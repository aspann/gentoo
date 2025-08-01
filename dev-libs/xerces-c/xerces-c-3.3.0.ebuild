# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake flag-o-matic prefix

DESCRIPTION="Validating XML parser written in a portable subset of C++"
HOMEPAGE="https://xerces.apache.org/xerces-c/"

if [[ ${PV} == *9999 ]] ; then
	ESVN_REPO_URI="https://svn.apache.org/repos/asf/xerces/c/trunk"
	inherit subversion
else
	SRC_URI="
		mirror://apache/xerces/c/3/sources/${P}.tar.xz
		https://archive.apache.org/dist/xerces/c/3/sources/${P}.tar.xz
	"
	KEYWORDS="~alpha amd64 arm arm64 ~hppa ~loong ppc ppc64 ~riscv ~s390 ~sparc x86 ~amd64-linux ~x86-linux ~x64-macos"
fi

LICENSE="Apache-2.0"
SLOT="0/$(ver_cut 1-2)"
IUSE="cpu_flags_x86_sse2 curl doc examples iconv icu static-libs test threads"

RESTRICT="!test? ( test )"

RDEPEND="
	curl? ( net-misc/curl )
	icu? ( dev-libs/icu:0= )
	virtual/libiconv"
DEPEND="${RDEPEND}"
BDEPEND="
	doc? ( app-text/doxygen )
	test? ( dev-lang/perl )"

DOCS=( CREDITS KEYS NOTICE README )

PATCHES=(
	"${FILESDIR}"/${PN}-3.2.4-strict-aliasing.patch
	"${FILESDIR}"/${PN}-3.2.5-cxx17.patch # bug 931105
	"${FILESDIR}"/${P}-symbol-name.patch # fixed in 3.3.1, see https://issues.apache.org/jira/browse/XERCESC-2255
)

pkg_setup() {
	export ICUROOT="${EPREFIX}/usr"

	if use iconv && use icu; then
		ewarn "This package can use iconv or icu for loading messages"
		ewarn "and transcoding, but not both. ICU takes precedence."
	fi
}

src_configure() {
	# bug #856100
	filter-lto
	append-flags -fno-strict-aliasing

	# 'cfurl' is only available on OSX and 'socket' isn't supposed to work.
	# But the docs aren't clear about it, so we would need some testing...
	local netaccessor
	if use curl; then
		netaccessor="curl"
	elif use elibc_Darwin; then
		netaccessor="cfurl"
	else
		netaccessor="socket"
	fi

	local msgloader
	if use icu; then
		msgloader="icu"
	elif use iconv; then
		msgloader="iconv"
	else
		msgloader="inmemory"
	fi

	local transcoder
	if use icu; then
		transcoder="icu"
	elif use elibc_Darwin; then
		transcoder="macosunicodeconverter"
	else
		transcoder="gnuiconv"
	fi

	local mycmakeargs=(
		-DCMAKE_INSTALL_DOCDIR="${EPREFIX}/usr/share/doc/${PF}"
		-Dnetwork-accessor="${netaccessor}"
		-Dmessage-loader="${msgloader}"
		-Dtranscoder="${transcoder}"
		-Dthreads:BOOL="$(usex threads)"
		-Dsse2:BOOL="$(usex cpu_flags_x86_sse2)"
	)

	cmake_src_configure
}

src_compile() {
	cmake_src_compile

	use doc && cmake_build doc-style createapidocs doc-xml
}

src_install() {
	cmake_src_install

	# package provides .pc files
	find "${D}" -name '*.la' -delete || die

	if use examples; then
		# clean out object files, executables, Makefiles
		# and the like before installing examples
		find samples/ \( -type f -executable -o -iname 'runConfigure' -o -iname '*.o' \
			-o -iname '.libs' -o -iname 'Makefile*' \) -exec rm -rf '{}' + || die
		docinto examples
		dodoc -r samples/.
		docompress -x /usr/share/doc/${PF}/examples
	fi

	# To make sure an appropriate NLS msg file is around when using
	# the iconv msgloader ICU has the messages compiled in.
	if use iconv && ! use icu; then
		doenvd "$(prefixify_ro "${FILESDIR}/50xerces-c")"
	fi
}
