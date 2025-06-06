# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MATE_LA_PUNT="yes"

inherit mate

MINOR=$(($(ver_cut 2) % 2))
if [[ ${MINOR} -eq 0 ]]; then
	KEYWORDS="~amd64 ~arm ~arm64 ~loong ~riscv ~x86"
fi

DESCRIPTION="The MATE panel"
LICENSE="FDL-1.1+ GPL-2+ LGPL-2+"
SLOT="0"

IUSE="+X +introspection wayland"

REQUIRED_USE="|| ( X wayland )"

COMMON_DEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	>=dev-libs/glib-2.50:2
	>=dev-libs/libmateweather-1.28.0
	dev-libs/libxml2:2=
	>=gnome-base/dconf-0.13.4
	>=gnome-base/dconf-editor-43.0
	>=mate-base/mate-desktop-$(ver_cut 1-2)
	>=mate-base/mate-menus-1.28.0
	>=sys-apps/dbus-1.1.2
	>=x11-libs/cairo-1.0.0[X?]
	>=x11-libs/gdk-pixbuf-2.26.0:2
	>=x11-libs/gtk+-3.22:3[introspection?]
	x11-libs/libICE
	x11-libs/libSM
	>=x11-libs/libwnck-3.4.6:3[introspection?]
	>=x11-libs/pango-1.15.4:0[introspection?]
	X? (
		x11-libs/libX11
		x11-libs/libXau
		>=x11-libs/libXrandr-1.3
	)
	introspection? ( >=dev-libs/gobject-introspection-0.6.7:= )
	wayland? ( gui-libs/gtk-layer-shell )
"

RDEPEND="${COMMON_DEPEND}
	virtual/libintl
"

DEPEND="${COMMON_DEPEND}"

BDEPEND="
	app-text/docbook-xml-dtd:4.1.2
	app-text/yelp-tools
	>=dev-lang/perl-5:=
	dev-util/glib-utils
	dev-util/gdbus-codegen
	dev-util/gtk-doc
	dev-build/gtk-doc-am
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"

src_configure() {
	mate_src_configure \
		--libexecdir="${EPREFIX}"/usr/libexec/mate-applets \
		--disable-deprecation-flags \
		$(use_enable X x11) \
		$(use_enable introspection) \
		$(use_enable wayland)
}
