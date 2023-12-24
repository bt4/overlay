# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

MY_COMMIT="a359c1e9e345061ec4149b1b384b7a452284935b"
MY_SHORT_COMMIT=$(c=${MY_COMMIT}; echo ${c:0:7})
MY_LIBDIR="/usr/lib64"

DESCRIPTION="Hardware abstraction layer for Intel IPU"
HOMEPAGE="https://github.com/intel/ipu6-drivers"
SRC_URI="https://github.com/intel/${PN}/archive/${MY_COMMIT}/${PN}-${MY_SHORT_COMMIT}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="sys-firmware/ipu6-camera-bins"

S=${WORKDIR}/${PN}-${MY_COMMIT}

src_prepare() {
	eapply_user
	cp src/platformdata/PlatformData.h src/platformdata/PlatformData.h.orig
	for i in ipu6 ipu6ep; do
		cp src/platformdata/PlatformData.h.orig src/platformdata/PlatformData.h.${i}
		cp src/platformdata/PlatformData.h.${i} src/platformdata/PlatformData.h
		sed -i "s|/usr/share/defaults/etc/camera/|/usr/share/defaults/etc/${i}/|g" src/platformdata/PlatformData.h
		CMAKE_USE_DIR=${S}
		BUILD_DIR=${WORKDIR}/${PN}-${MY_COMMIT}/${i}
		cmake_src_prepare
	done
}

src_configure() {
	for i in ipu6 ipu6ep; do
		#sed -i.orig "s|/usr/share/defaults/etc/camera/|/usr/share/defaults/etc/${i}/|g" src/platformdata/PlatformData.h
		export PKG_CONFIG_PATH=${MY_LIBDIR}/${i}/pkgconfig/
		export LDFLAGS="-Wl,-rpath=${MY_LIBDIR}/${i}"
		S=${WORKDIR}/${PN}-${MY_COMMIT}/${i}
		local mycmakeargs=(
			-DCMAKE_BUILD_TYPE=Release
			-DIPU_VER=${i}
			-DENABLE_VIRTUAL_IPU_PIPE=OFF
			-DUSE_PG_LITE_PIPE=ON
			-DUSE_STATIC_GRAPH=OFF
			..
		)
		CMAKE_USE_DIR=${S}
		BUILD_DIR=${WORKDIR}/${PN}-${MY_COMMIT}/${i}
		cmake_src_configure
		#mv src/platformdata/PlatformData.h.orig src/platformdata/PlatformData.h
	done
}

src_compile() {
	for i in ipu6 ipu6ep; do
		#sed -i.orig "s|/usr/share/defaults/etc/camera/|/usr/share/defaults/etc/${i}/|g" src/platformdata/PlatformData.h
		S=${WORKDIR}/${PN}-${MY_COMMIT}/$i
		CMAKE_USE_DIR=${S}
		BUILD_DIR=${WORKDIR}/${PN}-${MY_COMMIT}/${i}
		cmake_src_compile
		#mv src/platformdata/PlatformData.h.orig src/platformdata/PlatformData.h
	done
}

src_test() {
	for i in ipu6 ipu6ep; do
		S=${WORKDIR}/${PN}-${MY_COMMIT}/${i}
		cmake_src_test
	done
}

src_install() {
	for i in ipu6 ipu6ep; do
		MY_FILES=${WORKDIR}/${PN}-${MY_COMMIT}
		insinto /usr/share/defaults/etc
		doins -r ${MY_FILES}/config/linux/${i}
		insinto /usr/lib64/${i}
		insopts -m755
		chrpath --delete ${MY_FILES}/${i}/*.so
		patchelf --set-rpath /usr/lib64/${i} ${MY_FILES}/${i}/*.so
		doins ${MY_FILES}/${i}/*.so
		insopts -m644
		insinto /usr/lib/udev/rules.d
		doins ${FILESDIR}/60-intel-ipu6.rules
		insinto /usr/lib/modprobe.d
		insopts -m644
		doins ${FILESDIR}/intel_ipu6_isys.conf
		dosym /run/libcamhal.so /usr/lib64/libcamhal.so
	done
	insinto /usr/share/defaults/etc/ipu6ep
	insopts -m644
	doins ${FILESDIR}/v4l2-relayd-adl
	insinto /usr/share/defaults/etc/ipu
	insopts -m644
	doins ${FILESDIR}/v4l2-relayd-tgl

	insinto /usr/include/libcamhal
	insopts -m644
	doins -r ${MY_FILES}/include/*

	insinto /usr/lib64/pkgconfig
	insopts -m644
	doins ${MY_FILES}/libcamhal.pc
}

pkg_postinst() {
	if [ -S /run/udev/control ]; then
		/bin/udevadm control --reload
		/bin/udevadm trigger /sys/devices/pci0000:00/0000:00:05.0
	fi
}
