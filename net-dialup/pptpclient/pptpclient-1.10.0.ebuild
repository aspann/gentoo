# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs

MY_P="${P/client}"
MY_CMD="pptp-command-20130515"

DESCRIPTION="Linux client for PPTP"
HOMEPAGE="http://pptpclient.sourceforge.net/"
SRC_URI="https://downloads.sourceforge.net/pptpclient/${MY_P}.tar.gz
	https://dev.gentoo.org/~pinkbyte/distfiles/pptpclient/${MY_CMD}.bz2"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~alpha amd64 ~arm arm64 ~loong ppc ppc64 ~riscv ~sparc x86"
IUSE="tk"

DEPEND="net-dialup/ppp
	dev-lang/perl
	tk? ( dev-perl/Tk )"
RDEPEND="${DEPEND}
	sys-apps/iproute2"

RESTRICT="test" #make test is useless and vector_test.c is broken

S="${WORKDIR}/${MY_P}"

DOCS=( AUTHORS ChangeLog DEVELOPERS NEWS README TODO USING )

src_compile() {
	emake OPTIMISE= DEBUG= CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" CC="$(tc-getCC)"
}

src_install() {
	default
	dodoc Documentation/*
	dodir /etc/pptp.d

	# The current version of pptp-linux doesn't include the
	# RH-specific portions, so include them ourselves.
	newsbin "${WORKDIR}/${MY_CMD}" pptp-command
	dosbin "${FILESDIR}/pptp_fe.pl"
	use tk && dosbin "${FILESDIR}/xpptp_fe.pl"
}
