# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit linux-info linux-mod toolchain-funcs
inherit git-r3

MY_COMMIT="2c9b67072b15d903fecde67c7f269abeafee4c25"
MY_SHORT_COMMIT=$(c=${MY_COMMIT}; echo ${c:0:7})

KEYWORDS="~amd64"
EGIT_REPO_URI="https://github.com/umlaeute/v4l2loopback.git"
EGIT_COMMIT="${MY_COMMIT}"

DESCRIPTION="v4l2 loopback device whose output is its own input"
HOMEPAGE="https://github.com/umlaeute/v4l2loopback"

LICENSE="GPL-2"
SLOT="0"
IUSE="examples"

CONFIG_CHECK="VIDEO_DEV"
MODULE_NAMES="v4l2loopback(video:)"
BUILD_TARGETS="all"

KBUILD_OUTPUT=""

LDFLAGS_amd64=""

PATCHES=(
	"${FILESDIR}/0001-v4l2loopback-Fixup-bytesused-field-when-writer-sends.patch"
)

DEPEND="
	virtual/linux-sources
	sys-kernel/linux-headers
"

pkg_setup() {
	linux-mod_pkg_setup
	export KERNELRELEASE=${KV_FULL}
}

src_prepare() {
	default
	sed -i -e 's/gcc /$(CC) /' examples/Makefile || die
	BUILD_PARAMS="CC=$(tc-getCC)"
}

src_compile() {
	linux-mod_src_compile
	if use examples; then
	   emake CC="$(tc-getCC)" -C examples
	fi
}

src_install() {
	linux-mod_src_install
	dosbin utils/v4l2loopback-ctl
	dodoc doc/kernel_debugging.txt
	dodoc doc/docs.txt
	if use examples; then
		dosbin examples/yuv4mpeg_to_v4l2
		docinto examples
		dodoc examples/{*.sh,*.c,Makefile}
	fi
	#insinto /usr/lib/modules-load.d
	#insopts -m644
	#doins ${FILESDIR}/v4l2loopback.conf
	#insinto /usr/lib/modprobe.d
	#insopts -m644
	#doins ${FILESDIR}/98-v4l2loopback.conf
}
