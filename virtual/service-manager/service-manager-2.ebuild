# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Virtual for various service managers"

SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~loong ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux ~arm64-macos ~ppc-macos ~x64-macos ~x64-solaris"
IUSE="systemd"

RDEPEND="
	!prefix-guest? (
		systemd? ( sys-apps/systemd )
		!systemd? ( || (
				sys-apps/openrc
				kernel_linux? ( || (
					sys-apps/s6-rc
					sys-process/runit
				) )
			)
		)
	)
"
