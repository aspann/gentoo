# Copyright 2019-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=flit
PYTHON_COMPAT=( python3_{10..13} )

inherit distutils-r1

DESCRIPTION="Python logging made (stupidly) simple"
HOMEPAGE="
	https://github.com/Delgan/loguru/
	https://pypi.org/project/loguru/
"
SRC_URI="
	https://github.com/Delgan/loguru/archive/${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

BDEPEND="
	test? (
		>=dev-python/colorama-0.4.6[${PYTHON_USEDEP}]
		>=dev-python/freezegun-1.5.0[${PYTHON_USEDEP}]
	)
"

# filesystem buffering tests may fail
# on tmpfs with 64k PAGESZ, but pass fine on ext4
distutils_enable_tests pytest

EPYTEST_IGNORE=(
	# mypy
	tests/test_type_hinting.py
)

src_prepare() {
	distutils-r1_src_prepare

	# neuter mypy integration
	sed -i -e 's:sys.version_info >= (3, 6):False:' tests/conftest.py || die
}
