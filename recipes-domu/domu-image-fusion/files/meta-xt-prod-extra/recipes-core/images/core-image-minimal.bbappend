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
