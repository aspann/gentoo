# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools

DESCRIPTION="GeoIP Legacy C API"
HOMEPAGE="https://github.com/maxmind/geoip-api-c"
SRC_URI="https://github.com/maxmind/${PN}-api-c/archive/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-api-c-${PV}"

# GPL-2 for md5.c - part of libGeoIPUpdate, MaxMind for GeoLite Country db
LICENSE="LGPL-2.1 GPL-2 MaxMind2"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 ~hppa ~loong ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux"
IUSE="static-libs"
#RESTRICT="test"

DEPEND="net-misc/wget"
RDEPEND="${DEPEND}"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf $(use_enable static-libs static)
	sed -e "s|@PREFIX@|${EPREFIX}|g" "${FILESDIR}"/geoipupdate-r7.sh > geoipupdate.sh || die
}

src_install() {
	default

	dodoc AUTHORS ChangeLog NEWS.md README*

	find "${ED}" -name '*.la' -delete || die

	keepdir /usr/share/GeoIP

	dosbin geoipupdate.sh
}

pkg_postinst() {
	ewarn "WARNING: Databases are no longer installed by this ebuild."
	elog "Don't forget to run 'geoipupdate.sh -f' (or geoipupdate from"
	elog "net-misc/geoipupdate) to populate ${EROOT}/usr/share/GeoIP/"
	elog "with geo-located IP address databases."
}
