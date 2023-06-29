# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools

MY_COMMIT="3b7cdb93071360aacebb4e808ee71bb47cf90b30"
MY_SHORT_COMMIT=$(c=${MY_COMMIT}; echo ${c:0:7})
MY_LIBDIR="/usr/lib64"

DESCRIPTION="GStreamer 1.0 Intel IPU6 camera plug-in"
HOMEPAGE="https://github.com/intel/ipu6-drivers"
SRC_URI="https://github.com/intel/icamerasrc/archive/${MY_COMMIT}/icamerasrc-${MY_SHORT_COMMIT}.tar.gz"

LICENSE="LGPLv2"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="sys-firmware/ipu6-camera-bins
		 sys-apps/ipu6-camera-hal"

RDEPEND="x11-libs/libdrm
		 media-libs/gst-plugins-base"

S=${WORKDIR}/icamerasrc-${MY_COMMIT}

src_prepare() {
	export CHROME_SLIM_CAMHAL=ON
	export STRIP_VIRTUAL_CHANNEL_CAMHAL=ON
	default
	eautoreconf
}

src_configure() {
	#elog "$(tree .)"
	export CHROME_SLIM_CAMHAL=ON
	export STRIP_VIRTUAL_CHANNEL_CAMHAL=ON
	econf
}

src_install() {
	default
	find "${ED}" -type f -name '*.la' -delete || die
}
