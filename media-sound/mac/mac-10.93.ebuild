# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CMAKE_BUILD_TYPE=Release
inherit cmake

DESCRIPTION="Monkey's Audio Codecs"
HOMEPAGE="https://www.monkeysaudio.com"
SRC_URI="https://monkeysaudio.com/files/MAC_${PV/.}_SDK.zip -> ${P}.zip"

LICENSE="BSD"
SLOT="0/12"
KEYWORDS="~alpha ~amd64 ~loong ~ppc ~ppc64 ~riscv ~sparc ~x86"

BDEPEND="app-arch/unzip"

PATCHES=(
	"${FILESDIR}/${PN}-10.18-linux.patch"
	"${FILESDIR}/${PN}-10.52-output.patch"
)

src_unpack() {
	mkdir -p "${S}" || die
	cd "${S}" || die
	default
}
