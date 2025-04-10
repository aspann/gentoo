# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit go-module shell-completion

MY_PN="flux2"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Flux is a tool for keeping Kubernetes clusters in sync"
HOMEPAGE="https://fluxcd.io https://github.com/fluxcd/flux2"
SRC_URI="https://github.com/fluxcd/flux2/archive/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://dev.gentoo.org/~concord/distfiles/${MY_P}-deps.tar.xz"
# Manifests require kustomize to build. Do it with: make cmd/flux/.manifests.done
SRC_URI+=" https://dev.gentoo.org/~concord/distfiles/${MY_P}-manifests.tar.xz"
S="${WORKDIR}/${MY_P}"

LICENSE="Apache-2.0 BSD BSD-2 ISC MIT MPL-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="hardened"

BDEPEND=">=dev-lang/go-1.19"

RESTRICT+=" test"

src_compile() {
	mv "${WORKDIR}"/manifests cmd/"${PN}" || die
	CGO_LDFLAGS="$(usex hardened '-fno-PIC ' '')" \
		ego build -ldflags="-s -w -X main.VERSION=${PV}" -o ./bin/${PN} ./cmd/${PN}
}

src_install() {
	dobin bin/${PN}
	bin/${PN} completion bash > ${PN}.bash || die
	bin/${PN} completion zsh > ${PN}.zsh || die
	newbashcomp ${PN}.bash ${PN}
	newzshcomp ${PN}.zsh _${PN}
}
