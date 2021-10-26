VIRTUAL-RUNTIME_dev_manager ?= "busybox-mdev"

PACKAGE_INSTALL = "initramfs-framework-base busybox"

# Do not pollute the initrd image with rootfs features
IMAGE_FEATURES = ""

export IMAGE_BASENAME = "core-image-tiny-initramfs"

COMPATIBLE_HOST= "aarch64.*-linux"

#DEPLOYDIR = "${XT_DIR_ABS_SHARED_INITRAMFS_DOMD}"
IMAGE_LINK_NAME = "uInitramfs.cpio.gz"

