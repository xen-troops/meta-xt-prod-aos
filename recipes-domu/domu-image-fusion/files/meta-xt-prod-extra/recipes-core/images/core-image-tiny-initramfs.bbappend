VIRTUAL-RUNTIME_dev_manager ?= "busybox-mdev"

PACKAGE_INSTALL = "initramfs-framework-base busybox"

# Do not pollute the initrd image with rootfs features
IMAGE_FEATURES = ""

export IMAGE_BASENAME = "core-image-tiny-initramfs"

COMPATIBLE_HOST= "aarch64.*-linux"

require inc/xt_shared_env.inc

DEPLOYDIR = "${XT_DIR_ABS_SHARED_INITRAMFS_DOMF}"
IMAGE_LINK_NAME = "uInitramfs.cpio.gz"

deploy_to_shared_rootfs[cleandirs] += "${DEPLOYDIR}"

deploy_to_shared_rootfs() {
    IMAGE_FULL_NAME=${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.cpio.gz
    cp -rf ${IMGDEPLOYDIR}/${IMAGE_FULL_NAME} ${DEPLOYDIR}
    cd ${DEPLOYDIR}
    ln -sf ${IMAGE_FULL_NAME} ${IMAGE_LINK_NAME}
    cd -
}

IMAGE_POSTPROCESS_COMMAND += "deploy_to_shared_rootfs; "
