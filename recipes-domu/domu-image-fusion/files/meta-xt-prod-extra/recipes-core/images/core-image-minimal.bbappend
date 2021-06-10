require inc/xt_shared_env.inc

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

# Vars

SHARED_ROOTFS_DIR = "${XT_DIR_ABS_SHARED_ROOTFS_DOMF}/${IMAGE_BASENAME}"

# Dependencies

create_shared_links[dirs] = "${SHARED_ROOTFS_DIR}"

# Tasks

set_image_version() {
    install -d ${IMAGE_ROOTFS}/etc/aos

    echo "VERSION=\"${DOMF_IMAGE_VERSION}\"" > ${IMAGE_ROOTFS}/etc/aos/version
}

# We need to have shared resources in work-shared dir for the layer and update functionality
# Creating symlink IMAGE_ROOTFS to work-shared to get an access to them by
# layers and update
create_shared_links() {
    if [ -d ${IMAGE_ROOTFS} ]; then
        rm -rf ${SHARED_ROOTFS_DIR}
        lnr ${IMAGE_ROOTFS} ${SHARED_ROOTFS_DIR}
    fi
}
