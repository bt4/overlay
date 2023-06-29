# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-mod toolchain-funcs

inherit git-r3

MY_COMMIT_IPU6="8e410803b5d31c2c5bf32961f786d205ba6acc5d"
MY_SHORT_COMMIT_IPU6=$(c=${MY_COMMIT_IPU6}; echo ${c:0:7})
MY_COMMIT_IVSC="c8db12b907e2e455d4d5586e5812d1ae0eebd571"
MY_SHORT_COMMIT_IVSC=$(c=${MY_COMMIT_IVSC}; echo ${c:0:7})

EGIT_REPO_URI="https://github.com/intel/ipu6-drivers.git"
EGIT_COMMIT="${MY_COMMIT_IPU6}"
IVSC_REPO_URI="https://github.com/intel/ivsc-driver.git"

DESCRIPTION="Drivers for MIPI cameras through the IPU6 on Intel Tiger Lake and Alder Lake platforms."
HOMEPAGE="https://github.com/intel/ipu6-drivers"

SLOT="0"
LICENSE="GPL-2"
IUSE=""

DEPEND="
	virtual/linux-sources
	sys-kernel/linux-headers
"
RDEPEND=""

MODULE_NAMES="	hm11b1(drivers/media/i2c:${S}:drivers/media/i2c) \
				hm2170(drivers/media/i2c:${S}:drivers/media/i2c) \
				ov01a10(drivers/media/i2c:${S}:drivers/media/i2c) \
				ov01a1s(drivers/media/i2c:${S}:drivers/media/i2c) \
				ov02c10(drivers/media/i2c:${S}:drivers/media/i2c) \
				ov2740(drivers/media/i2c:${S}:drivers/media/i2c) \
				intel-ipu6(drivers/media/pci/intel/ipu6:${S}:drivers/media/pci/intel/ipu6) \
				intel-ipu6-isys(drivers/media/pci/intel/ipu6:${S}:drivers/media/pci/intel/ipu6) \
				intel-ipu6-psys(drivers/media/pci/intel/ipu6:${S}:drivers/media/pci/intel/ipu6) \
				mei-vsc(updates) \
				intel_vsc(updates) \
				i2c-ljca(updates) \
				gpio-ljca(updates) \
				ljca(updates) \
				mei_ace(updates) \
				mei_ace_debug(updates) \
				mei_csi(updates) \
				mei_pse(updates) \
				spi-ljca(updates)"

src_unpack() {
	git-r3_src_unpack
	pushd "${P}" >/dev/null || die
	git-r3_fetch "${IVSC_REPO_URI}" "${MY_COMMIT_IVSC}"
	git-r3_checkout "${IVSC_REPO_URI}" ivsc-driver

	cp -vr ivsc-driver/backport-include ivsc-driver/drivers ivsc-driver/include .
	rm -rf ivsc-driver
	popd >/dev/null || die
	# sed -i s/"# export CONFIG_POWER_CTRL_LOGIC = m"/"export CONFIG_POWER_CTRL_LOGIC = m"/ "${S}/Makefile"
}

pkg_setup() {
	linux-mod_pkg_setup

	BUILD_TARGETS="clean all"
	# BUILD_PARAMS="KVERSION=${KV_FULL} CC=$(tc-getCC)"
}

src_compile() {
	KBUILD_MODPOST_WARN=1 linux-mod_src_compile
}

src_install() {
	linux-mod_src_install
}
