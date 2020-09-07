IMAGE_INSTALL_append = " \
    tzdata \
    aos-servicemanager \
    aos-updatemanager \
    logrotate \
    openssh-sshd \
    openssh-scp \
    haveged \
    openssl-bin \
"

inherit image

populate_vmlinux () {
    find ${STAGING_KERNEL_BUILDDIR} -iname "vmlinux*" -exec mv {} ${DEPLOY_DIR_IMAGE} \; || true
}

IMAGE_POSTPROCESS_COMMAND += "populate_vmlinux; "

IMAGE_FSTYPES = "tar.bz2 wic.vmdk wic.bz2"
WKS_FILE = "core-image-minimal.wks"
