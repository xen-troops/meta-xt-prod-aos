IMAGE_INSTALL_append = " \
    tzdata \
    aos-servicemanager \
    aos-updatemanager \
    logrotate \
    openssh-sshd \
    openssh-scp \
    haveged \
    openssl-bin \
    openssh-sshd \
    openssh-ssh \
    openssh-scp \
    volatile-binds \
"

populate_vmlinux () {
    find ${STAGING_KERNEL_BUILDDIR} -iname "vmlinux*" -exec mv {} ${DEPLOY_DIR_IMAGE} \; || true
}

IMAGE_POSTPROCESS_COMMAND += "populate_vmlinux; "
IMAGE_FEATURES_append = " read-only-rootfs"

BOARD_ROOTFS_VERSION ?= "${PV}"

do_set_rootfs_version() {
    install -d ${IMAGE_ROOTFS}/etc/aos

    echo "VERSION=\"${BOARD_ROOTFS_VERSION}\"" > ${IMAGE_ROOTFS}/etc/aos/version
}
addtask set_rootfs_version after do_rootfs before do_image_qa
