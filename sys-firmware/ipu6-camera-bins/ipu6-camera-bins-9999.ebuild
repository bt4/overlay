# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_COMMIT="4694ba7ee51652d29ef41e7fde846b83a2a1c53b"
MY_SHORT_COMMIT=$(c=${MY_COMMIT}; echo ${c:0:7})
MY_LIBDIR="/usr/lib64"

DESCRIPTION="Binary library for Intel IPU6"
HOMEPAGE="https://github.com/intel/ipu6-drivers"
SRC_URI="https://github.com/intel/${PN}/archive/${MY_COMMIT}/${PN}-${MY_SHORT_COMMIT}.tar.gz"

LICENSE="ipu6-camera-bins"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="app-admin/chrpath
		 dev-util/patchelf"

RDEPEND="media-video/ipu6-drivers"

S=${WORKDIR}/${PN}-${MY_COMMIT}

src_install() {
	for i in ipu6 ipu6ep; do
		elog "Rewriting runpath for $i libs"
		chrpath --delete $i/lib/*.so
		patchelf --set-rpath ${MY_LIBDIR}/$i $i/lib/*.so
		sed -i \
			-e "s|libdir=/usr/lib|libdir=${MY_LIBDIR}|g" \
			-e "s|libdir}|libdir}/$i|g" \
			-e "s|includedir}|includedir}/$i|g" \
			$i/lib/pkgconfig/*.pc
		# dolib.so doesn't work with custom paths
		insinto ${MY_LIBDIR}/$i
		insopts -m755
		doins $i/lib/*.so*

		insinto ${MY_LIBDIR}/$i/pkgconfig
		doins $i/lib/pkgconfig/*.pc

		# need to copy ipu6/include/ia_camera/GCSSParser.h to /usr/include/ipu6/ia_camera/GCSSParser.h
		insinto /usr/include/$i
		insopts -m644
		doins -r $i/include/*

		# do we need this?
		insinto ${MY_LIBDIR}/$i
		doins $i/lib/*.a
	done

	insinto /lib/firmware/intel/
	insopts -m644
	doins ipu6/lib/firmware/intel/ipu6_fw.bin
	doins ipu6ep/lib/firmware/intel/ipu6ep_fw.bin
}
