# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

if [[ ${PV} == 9999 ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/MariaDB/mariadb-connector-c.git"
else
	MY_PN=${PN#mariadb-}
	MY_PV=${PV/_b/-b}
	SRC_URI="https://downloads.mariadb.com/Connectors/c/connector-c-${PV}/${P}-src.tar.gz"
	S="${WORKDIR%/}/${PN}-${MY_PV}-src"
	KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~loong ~mips ~ppc ~ppc64 ~riscv ~s390 ~x86"
fi

inherit cmake-multilib flag-o-matic toolchain-funcs

DESCRIPTION="C client library for MariaDB/MySQL"
HOMEPAGE="https://mariadb.org/"

LICENSE="LGPL-2.1"
SLOT="0/3"
IUSE="+curl gnutls kerberos +ssl static-libs test"
RESTRICT="!test? ( test )"

DEPEND="
	app-arch/zstd:=[${MULTILIB_USEDEP}]
	sys-libs/zlib:=[${MULTILIB_USEDEP}]
	virtual/libiconv:=[${MULTILIB_USEDEP}]
	curl? ( net-misc/curl[${MULTILIB_USEDEP}] )
	kerberos? (
		|| (
			app-crypt/mit-krb5[${MULTILIB_USEDEP}]
			app-crypt/heimdal[${MULTILIB_USEDEP}]
		)
	)
	ssl? (
		gnutls? ( >=net-libs/gnutls-3.3.24:=[${MULTILIB_USEDEP}] )
		!gnutls? ( dev-libs/openssl:=[${MULTILIB_USEDEP}] )
	)
"
BDEPEND="test? ( dev-db/mariadb[server] )"
RDEPEND="${DEPEND}
	!<dev-db/mariadb-11.4.7-r1
"

MULTILIB_CHOST_TOOLS=( /usr/bin/mariadb_config )
MULTILIB_WRAPPED_HEADERS+=( /usr/include/mariadb/mariadb_version.h )

PATCHES=(
	"${FILESDIR}"/${PN}-3.1.3-fix-pkconfig-file.patch
)

src_prepare() {
	local sedargs=(
		# These tests the remote_io plugin which requires network access
		-e '/{"test_remote1/s:{://&:'

		# These tests don't work with --skip-grant-tables
		-e '/{"test_conc366/s:{://&:'
		-e '/{"test_conc544/s:{://&:'
		-e '/{"test_conc627/s:{://&:'
		-e '/{"test_conc66/s:{://&:'

		# [Warning] Aborted connection 2078 to db: 'test' user: 'root' host: '' (Got an error reading communication packets)
		# Not sure about this one - might also require network access
		-e '/{"test_default_auth/s:{://&:'

		# Not sure about this one eighter. It should fail on connection but it
		# does not. Maybe because we use domain socket?
		-e '/{"test_conc26/s:{://&:'
	)

	sed -i "${sedargs[@]}" unittest/libmariadb/{connection,misc,ps_bugs}.c || die

	cmake_src_prepare
}

src_configure() {
	# mariadb cannot use ld.gold, bug #508724
	tc-ld-is-gold && tc-ld-force-bfd

	# bug #943757
	append-cflags -std=gnu17

	cmake-multilib_src_configure
}

multilib_src_configure() {
	local mycmakeargs=(
		-DWITH_EXTERNAL_ZLIB=ON
		-DWITH_SSL:STRING=$(usex ssl $(usex gnutls GNUTLS OPENSSL) OFF)
		-DWITH_CURL=$(usex curl)
		-DWITH_ICONV=ON
		-DCLIENT_PLUGIN_AUTH_GSSAPI_CLIENT:STRING=$(usex kerberos DYNAMIC OFF)
		-DMARIADB_UNIX_ADDR="${EPREFIX}/var/run/mysqld/mysqld.sock"
		-DINSTALL_LIBDIR="$(get_libdir)"
		-DINSTALL_MANDIR=share/man
		-DINSTALL_PCDIR="$(get_libdir)/pkgconfig"
		-DINSTALL_PLUGINDIR="$(get_libdir)/mariadb/plugin"
		-DINSTALL_BINDIR=bin
		-DWITH_UNIT_TESTS=$(usex test)
	)

	cmake_src_configure
}

multilib_src_test() {
	mkdir -vp "${T}/mysql/data" || die

	mysql_install_db --no-defaults --datadir="${T}/mysql/data" || die
	mysqld --no-defaults --datadir="${T}/mysql/data" --socket="${T}/mysql/mysql.sock" --skip-grant-tables --skip-networking &

	local attempts=0
	while ! mysqladmin ping --socket="${T}/mysql/mysql.sock" --silent ; do
		# 5 minutes should be more than enough
		if [[ ${attempts} -gt 300 ]] ; then
			die "mysqld not found after 300 seconds, aborting"
		fi

		sleep 1
		attempts=$((attempts + 1))
	done

	cd unittest/libmariadb || die
	MYSQL_TEST_SOCKET="${T}/mysql/mysql.sock" MARIADB_CC_TEST=1 ctest --verbose || die
}

multilib_src_install_all() {
	if ! use static-libs ; then
		find "${ED}" -name "*.a" -delete || die
	fi
}
