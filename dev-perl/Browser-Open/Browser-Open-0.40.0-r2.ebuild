# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DIST_AUTHOR=CFRANKS
DIST_VERSION=0.04
inherit perl-module

DESCRIPTION="Open a browser at a given URL"

SLOT="0"
KEYWORDS="~alpha amd64 ~arm arm64 ~hppa ~loong ~mips ppc ~ppc64 ~riscv ~s390 x86"

BDEPEND="
	test? (
		>=virtual/perl-Test-Simple-0.920.0
	)
"
