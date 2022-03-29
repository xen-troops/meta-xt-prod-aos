
IMAGE_INSTALL_append = " \
    tzdata \
    aos-communicationmanager \
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

IMAGE_POSTPROCESS_COMMAND += " populate_vmlinux; "
ROOTFS_POSTPROCESS_COMMAND += " set_image_version; "

IMAGE_FEATURES_append = " read-only-rootfs"

# Vars

SHARED_ROOTFS_DIR = "${XT_DIR_ABS_SHARED_ROOTFS_DOMF}/${IMAGE_BASENAME}"

# Dependencies


# Tasks

set_image_version() {
    install -d ${IMAGE_ROOTFS}/etc/aos

    echo "VERSION=\"${DOMF_IMAGE_VERSION}\"" > ${IMAGE_ROOTFS}/etc/aos/version
}

