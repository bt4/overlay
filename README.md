# My Gentoo overlay

This overlay contains some ebuilds I made to provide Intel IPU6 webcam support on Gentoo. It uses the kernel module ebuild from the [fol4 repository](https://github.com/gentoo-mirror/fol4) and the other packages are based on the [Fedora source rpms](https://github.com/intel/ipu6-drivers/issues/22#issuecomment-1562520821).

## Installation

First add the repository using eselect:
```
root # eselect repository add bt4 git https://github.com/bt4/overlay.git
root # emaint sync -r bt4
```

Next you need to emerge the following packages:
```
root # emerge -av media-video/ipu6-drivers sys-firmware/ipu6-camera-bins sys-firmware/ivsc-firmware sys-apps/ipu6-camera-hal media-plugins/gst-plugins-icamerasrc
```

At this point you should probably reboot and check that the modules have loaded:
```
$ dmesg | grep ipu6-isys
```
Should output something like:
```
[   16.433652] intel-ipu6-isys intel-ipu6-isys0: bind ov01a10 20-0036 nlanes is 1 port is 2
[   16.453412] intel-ipu6-isys intel-ipu6-isys0: All sensor registration completed.
```

However, in my case this is not sufficient. It appears that the modules must be loaded in a specific order and I haven't figured out how to force them load properly on boot. I have tried putting some of the modules into initramfs to make them load earlier, but as of the time of writing I have not had any success.

After boot I have to remove and reload the modules manaully as follows:
```
root # rmmod -f intel_ipu6_psys intel_ipu6_isys intel_ipu6 && modprobe -a intel_ipu6 intel_ipu6_isys intel_ipu6_psys
```

After running the above command check dmesg again to check for the message "All sensor registration completed". If it has worked then the next thing is to check that udev has added a symlnk to the correct libcamhal.so:
```
$ ls -l /run/libcamhal.so
lrwxrwxrwx 1 root root 30 Jun 28 16:53 /run/libcamhal.so -> /usr/lib64/ipu6ep/libcamhal.so
```
Depending on the version of camera you will either see /usr/lib64/ipu6ep or /usr/lib64/ipu6 as the target folder.

If the above symlink is in place then we can test the camera using gstreamer:
```
$ sudo GST_DEBUG=2 gst-launch-1.0 icamerasrc buffer-count=7 ! video/x-raw,format=NV12,width=1280,height=720 ! videoconvert ! ximagesink
```
This should display the image from your webcam in a new window.

Currently gstreamer is the only application which knows how to talk to the IPU6 cameras (via the icamerasrc plugin). In order to use the camera with other programmes (e.g. Firefox) you need to install v4l2loopback and v4l2-relayd. The idea is that v4l2-relayd will run gstreamer in the background and Firefox can then connect to this "virtual" webcam it as if it was a real webcam.

Install the two packages:
```
root # emerge -av media-video/v4l2loopback media-video/v4l2-relayd
```
You can then start v4l2-relayd using systemd:
```
root # systemctl enable v4l2-relayd
root # systemctl start v4l2-relayd
```
At this point you should can test the webcam in Firefox at: https://mozilla.github.io/webrtc-landing/gum_test.html
