# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DIST_AUTHOR=BOBERNST
DIST_VERSION=2.0.0
DIST_EXAMPLES=("samples/*")
inherit perl-module

DESCRIPTION='fetching weather information from weather.com'
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	dev-perl/HTTP-Message
	dev-perl/libwww-perl
	dev-perl/Test-MockObject
	>=dev-perl/Time-Format-1.0.0
	dev-perl/URI
	dev-perl/XML-Simple
"
BDEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}/${PN}-2.0.0-dotinc.patch"
	"${FILESDIR}/${PN}-2.0.0-network.patch"
)
