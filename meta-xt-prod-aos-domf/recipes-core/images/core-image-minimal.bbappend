
IMAGE_INSTALL_append = " \
    xen-tools \
    tzdata \
    aos-iamanager \
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

IMAGE_POSTPROCESS_COMMAND += " populate_vmlinux; create_shared_links; "
ROOTFS_POSTPROCESS_COMMAND += " set_image_version; "

IMAGE_FEATURES_append = " read-only-rootfs"


# Tasks

set_image_version() {
    install -d ${IMAGE_ROOTFS}/etc/aos

    echo "VERSION=\"${DOMF_IMAGE_VERSION}\"" > ${IMAGE_ROOTFS}/etc/aos/version
}

