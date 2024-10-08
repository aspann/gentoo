# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit elisp

DESCRIPTION="An Emacs major mode for editing Python source"
HOMEPAGE="http://ed.loper.org/projects/doctestmode/"
SRC_URI="http://python-mode.svn.sourceforge.net/viewvc/*checkout*/python-mode/trunk/python-mode/doctest-mode.el?revision=460 -> ${PN}.el"

LICENSE="HPND"
SLOT="0"
KEYWORDS="amd64 arm ~hppa ppc ppc64 x86"

S="${WORKDIR}"
SITEFILE="60${PN}-gentoo.el"

src_unpack() {
	cp "${DISTDIR}"/${PN}.el "${WORKDIR}"
}
