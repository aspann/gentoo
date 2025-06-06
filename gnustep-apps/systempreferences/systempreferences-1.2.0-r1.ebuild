# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit gnustep-2

MY_P=SystemPreferences-${PV}
DESCRIPTION="System Preferences is a clone of Apple OS X' System Preferences"
HOMEPAGE="http://www.gnustep.it/enrico/system-preferences/"
SRC_URI="https://ftp.gnustep.org/pub/gnustep/usr-apps/${MY_P}.tar.gz"

KEYWORDS="amd64 ppc x86"
LICENSE="GPL-2"
SLOT="0"
IUSE=""

S=${WORKDIR}/${MY_P}
