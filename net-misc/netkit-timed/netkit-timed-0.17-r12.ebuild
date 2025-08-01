# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit flag-o-matic toolchain-funcs

DESCRIPTION="Netkit - timed: Time daemon"
HOMEPAGE="https://wiki.linuxfoundation.org/networking/netkit"
SRC_URI="http://ftp.linux.org.uk/pub/linux/Networking/netkit/${P}.tar.gz"

LICENSE="BSD GPL-2"
SLOT="0"
KEYWORDS="amd64 ~mips ppc ppc64 sparc x86"

PATCHES=(
	"${FILESDIR}/0.17-CFLAG-DEF-fix.patch"
	"${FILESDIR}/0.17-timed-opt-parsing.patch"
	"${FILESDIR}/${P}-c99-port.patch"
	"${FILESDIR}/${P}-accept-build-flags.patch"
	"${FILESDIR}/${P}-c23-port.patch"
)

src_configure() {
	tc-export AR
	# Note this is not an autoconf configure script. econf fails
	append-flags -DCLK_TCK=CLOCKS_PER_SEC
	./configure --prefix=/usr --with-c-compiler="$(tc-getCC)" || die "bad configure"
}

src_install() {
	dosbin timed/timed/timed
	doman  timed/timed/timed.8
	dosbin timed/timedc/timedc
	doman  timed/timedc/timedc.8
	einstalldocs

	newinitd "${FILESDIR}"/timed.rc6 timed
}
