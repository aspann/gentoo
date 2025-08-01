# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop gnome.org gnome2-utils meson pam readme.gentoo-r1 systemd udev xdg

DESCRIPTION="GNOME Display Manager for managing graphical display servers and user logins"
HOMEPAGE="https://gitlab.gnome.org/GNOME/gdm"

SRC_URI="${SRC_URI}
	branding? ( https://www.mail-archive.com/tango-artists@lists.freedesktop.org/msg00043/tango-gentoo-v1.1.tar.gz )
"

LICENSE="
	GPL-2+
	branding? ( CC-BY-SA-4.0 )
"

SLOT="0"

KEYWORDS="amd64 ~arm ~arm64 ~loong ~ppc64 ~riscv x86"

IUSE="accessibility audit bluetooth-sound branding elogind fprint plymouth selinux systemd tcpd test wayland +X"

RESTRICT="!test? ( test )"
REQUIRED_USE="^^ ( elogind systemd ) || ( wayland X )"

# dconf, dbus and g-s-d are needed at install time for dconf update
# keyutils is automagic dep that makes autologin unlock login keyring
# when all the passwords match (disk encryption, user pw and login keyring)
# dbus-run-session used at runtime
COMMON_DEPEND="
	virtual/udev
	>=dev-libs/libgudev-232:=
	>=dev-libs/glib-2.68:2
	>=dev-libs/json-glib-1.2.0
	>=sys-apps/accountsservice-0.6.35
	sys-apps/keyutils:=
	selinux? ( sys-libs/libselinux )

	X? (
		x11-libs/libxcb
		x11-libs/libX11
		x11-libs/libXau
		x11-base/xorg-server[-minimal]
		x11-libs/libXdmcp
		>=x11-libs/gtk+-2.91.1:3
	)
	tcpd? ( >=sys-apps/tcp-wrappers-7.6 )

	systemd? ( >=sys-apps/systemd-186:0=[pam] )
	elogind? ( >=sys-auth/elogind-239.3[pam] )

	plymouth? ( sys-boot/plymouth )
	audit? ( sys-process/audit )

	sys-libs/pam
	sys-auth/pambase[elogind?,systemd?]

	>=gnome-base/dconf-0.20
	>=gnome-base/gnome-settings-daemon-3.1.4
	gnome-base/gsettings-desktop-schemas
	sys-apps/dbus

	>=x11-misc/xdg-utils-1.0.2-r3

	>=dev-libs/gobject-introspection-0.9.12:=
"
# XXX: These deps are from session and desktop files in data/ directory
# fprintd is used via dbus by gdm-fingerprint-extension
RDEPEND="${COMMON_DEPEND}
	acct-group/gdm
	acct-user/gdm
	>=gnome-base/gnome-session-3.6
	>=gnome-base/gnome-shell-3.1.90
	x11-apps/xhost

	accessibility? (
		>=app-accessibility/orca-3.10
		gnome-extra/mousetweaks
	)
	fprint? ( sys-auth/fprintd[pam] )
"
DEPEND="${COMMON_DEPEND}
	x11-base/xorg-proto
"
BDEPEND="
	dev-util/gdbus-codegen
	dev-util/glib-utils
	dev-util/itstool
	>=gnome-base/dconf-0.20
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	test? ( >=dev-libs/check-0.9.4 )
"

DOC_CONTENTS="
	To start GDM at boot with systemd, run:\n
	# systemctl enable gdm.service\n
	\n
	To start GDM at boot with OpenRC, set DISPLAYMANAGER=\"gdm\"\n
	in /etc/conf.d/display-manager and enable the display-manager service:\n
	# rc-update add display-manager\n
	\n
	For passwordless login to unlock your keyring, you need to install
	sys-auth/pambase with USE=gnome-keyring and set an empty password
	on your keyring. Use app-crypt/seahorse for that.\n
	\n
	You may need to install app-crypt/coolkey and sys-auth/pam_pkcs11
	for smartcard support
"

src_prepare() {
	default

	# Show logo when branding is enabled
	use branding && eapply "${FILESDIR}/${PN}-3.30.3-logo.patch"

	eapply "${FILESDIR}/47.0-c23.patch"
}

src_configure() {
	# --with-initial-vt=7 conflicts with plymouth, bug #453392
	# gdm-3.30 now reaps (stops) the login screen when the login VT isn't active, which
	# saves on memory. However this means if we don't start on VT1, gdm doesn't start up
	# before user manually goes to VT7. Thus as-is we can not keep gdm away from VT1,
	# so lets try always having it in VT1 and see if that is an issue for people before
	# hacking up workarounds for the initial start case.
	local emesonargs=(
		--localstatedir /var

		-Ddefault-pam-config=exherbo
		-Dgdm-xsession=true
		-Dgroup=gdm
		-Dipv6=true
		$(meson_feature audit libaudit)
		-Dlogind-provider=$(usex systemd systemd elogind)
		-Dpam-mod-dir=$(getpam_mod_dir)
		$(meson_feature plymouth)
		-Drun-dir=/run/gdm
		$(meson_feature selinux)
		$(meson_use systemd systemd-journal)
		$(meson_use tcpd tcp-wrappers)
		-Dudev-dir=$(get_udevdir)/rules.d
		-Duser=gdm
		-Duser-display-server=true
		$(meson_use wayland wayland-support)
		$(meson_use X x11-support)
		$(meson_feature X xdmcp)
	)

	if use elogind; then
		emesonargs+=(
			-Dinitial-vt=7 # TODO: Revisit together with startDM.sh and other xinit talks; also ignores plymouth possibility
			-Dsystemdsystemunitdir=no
			-Dsystemduserunitdir=no
		)
	else
		emesonargs+=(
			-Dinitial-vt=1
			-Dsystemdsystemunitdir="$(systemd_get_systemunitdir)"
			-Dsystemduserunitdir="$(systemd_get_userunitdir)"
		)
	fi

	meson_src_configure
}

src_install() {
	meson_src_install

	if ! use accessibility ; then
		rm "${ED}"/usr/share/gdm/greeter/autostart/orca-autostart.desktop || die
	fi

	if ! use bluetooth-sound ; then
		# Workaround https://gitlab.freedesktop.org/pulseaudio/pulseaudio/merge_requests/10
		# bug #679526
		insinto /var/lib/gdm/.config/pulse
		doins "${FILESDIR}"/default.pa
	fi

	# install XDG_DATA_DIRS gdm changes
	echo 'XDG_DATA_DIRS="/usr/share/gdm"' > 99xdg-gdm
	doenvd 99xdg-gdm

	use branding && newicon "${WORKDIR}/tango-gentoo-v1.1/scalable/gentoo.svg" gentoo-gdm.svg

	readme.gentoo_create_doc
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update

	local d ret

	# bug #669146; gdm may crash if /var/lib/gdm subdirs are not owned by gdm:gdm
	ret=0
	ebegin "Fixing ${EROOT}/var/lib/gdm ownership"
	chown --no-dereference gdm:gdm "${EROOT}/var/lib/gdm" || ret=1
	for d in "${EROOT}/var/lib/gdm/"{.cache,.color,.config,.dbus,.local}; do
		[[ ! -e "${d}" ]] || chown --no-dereference -R gdm:gdm "${d}" || ret=1
	done
	eend ${ret}

	systemd_reenable gdm.service
	readme.gentoo_print_elog

	udev_reload
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
	udev_reload
}
