# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_COMMIT="29c5eff4cdaf83e90ef2dcd2035a9cdff6343430"
MY_SHORT_COMMIT=$(c=${MY_COMMIT}; echo ${c:0:7})
MY_LIBDIR="/usr/lib64"

DESCRIPTION="This provides the necessary firmware for Intel iVSC"
HOMEPAGE="https://github.com/intel/ivsc-firmware"
SRC_URI="https://github.com/intel/${PN}/archive/${MY_COMMIT}/${PN}-${MY_SHORT_COMMIT}.tar.gz"

LICENSE="ivsc-firmware"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="media-video/ipu6-drivers"

S=${WORKDIR}/${PN}-${MY_COMMIT}/firmware

src_install() {
	for i in *.bin; do
		insinto /lib/firmware/vsc/soc_a1
		insopts -m644
		newins "${i}" $(echo "${i}" | sed 's|\.bin|_a1\.bin|')
		insinto /lib/firmware/vsc/soc_a1_prod
		insopts -m644
		newins "${i}" $(echo "${i}" | sed 's|\.bin|_a1_prod\.bin|')
	done
}
