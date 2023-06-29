# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3
inherit autotools

MY_COMMIT="2e4d5c9ba53bfe8cfe16ea91932c8e5ecb090a87"
MY_SHORT_COMMIT="$(c=${MY_COMMIT}; echo ${c:0:7})"

DESCRIPTION="Streaming relay for v4l2loopback using GStreamer"
HOMEPAGE="https://gitlab.com/vicamo/v4l2-relayd"
EGIT_REPO_URI="https://gitlab.com/vicamo/v4l2-relayd"
EGIT_COMMIT="${MY_COMMIT}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

PATCHES=(
	"${FILESDIR}/0001-Set-a-new-ID-offset-for-the-private-event.patch"
)

src_prepare() {
	sed -i "s|#VIDEOSRC=\"videotest\"|VIDEOSRC=\"icamerasrc\"|g" data/etc/default/v4l2-relayd
	sed -i "s|#FORMAT=YUV2|FORMAT=NV12|g" data/etc/default/v4l2-relayd
	sed -i "s|#WIDTH=1280|WIDTH=1280|g" data/etc/default/v4l2-relayd
	sed -i "s|#HEIGHT=720|HEIGHT=720|g" data/etc/default/v4l2-relayd
	sed -i "s|#FRAMERATE=30/1|FRAMERATE=30/1|g" data/etc/default/v4l2-relayd
	sed -i "s|#CARD_LABEL=\"Virtual Camera\"|CARD_LABEL=\"Virtual Camera\"|g" data/etc/default/v4l2-relayd
	default
	eautoreconf
}

src_configure() {
	econf
}

src_install() {
	emake DESTDIR="${D}" install
}
