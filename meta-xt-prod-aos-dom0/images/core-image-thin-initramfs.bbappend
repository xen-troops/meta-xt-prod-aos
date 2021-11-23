DEPENDS += "u-boot-mkimage-native"

inherit deploy

XT_GUESTS_INSTALL ?= "doma domf"

python __anonymous () {
    guests = d.getVar("XT_GUESTS_INSTALL", True).split()
    if "domf" in guests :
        d.appendVar("IMAGE_INSTALL", " domf")
}

generate_uboot_image() {
    ${STAGING_BINDIR_NATIVE}/uboot-mkimage -A arm64 -O linux -T ramdisk -C gzip -n "uInitramfs" \
        -d ${DEPLOYDIR}-image-complete/${IMAGE_LINK_NAME}.cpio.gz ${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.cpio.gz.uInitramfs
    ln -sfr  ${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.cpio.gz.uInitramfs ${DEPLOY_DIR_IMAGE}/uInitramfs
}

populate_vmlinux () {
    find ${STAGING_KERNEL_BUILDDIR} -iname "vmlinux*" -exec mv {} ${DEPLOY_DIR_IMAGE} \; || true
}

set_image_version() {
    install -d ${DEPLOY_DIR_IMAGE}/aos
    echo "VERSION=\"${DOM0_IMAGE_VERSION}\"" > ${DEPLOY_DIR_IMAGE}/aos/version
}

IMAGE_POSTPROCESS_COMMAND += " generate_uboot_image; populate_vmlinux; set_image_version; "

IMAGE_ROOTFS_SIZE = "65535"
