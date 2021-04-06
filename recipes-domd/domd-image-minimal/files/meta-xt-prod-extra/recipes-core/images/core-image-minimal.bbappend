require inc/xt_shared_env.inc

IMAGE_INSTALL_append = " \
    packagegroup-xt-core-guest-addons \
    packagegroup-xt-core-xen \
    packagegroup-xt-core-network \
    kernel-modules \
    optee-os \
    libxenbe \
    openssh-sshd \
    openssh-ssh \
    openssh-scp \
    volatile-binds \
"

# Add python3 and modules required for provisioning
IMAGE_INSTALL_append = " \
    python3 \
    python3-compression \
    python3-core \
    python3-crypt \
    python3-json \
    python3-misc \
    python3-shell \
    python3-six \
    python3-threading \
    python3-websocket-client \
"

# Add aos components
IMAGE_INSTALL_append = " \
    aos-updatemanager \
    aos-iamanager \
"

IMAGE_INSTALL_append_cetibox = " \
    sja1105-tool \
    phytool \
    devmem2 \
"

python __anonymous () {
    if (d.getVar("AOS_VIS_PACKAGE_DIR", True) or "") == "":
        d.appendVar("IMAGE_INSTALL", "aos-vis")
}

# Configuration for ARM Trusted Firmware
EXTRA_IMAGEDEPENDS += " arm-trusted-firmware"

# u-boot
DEPENDS += " u-boot"

# Do not support secure environment
IMAGE_INSTALL_remove = " \
    optee-linuxdriver \
    optee-linuxdriver-armtz \
    optee-client \
    libx11-locale \
    dhcp-client \
"

# Use only provided proprietary graphic modules
IMAGE_INSTALL_remove = " \
    packagegroup-graphics-renesas-proprietary \
"

IMAGE_INSTALL_append_kingfisher = " \
    iw \
"

IMAGE_INSTALL_remove_kingfisher = " \
    wireless-tools \
"

CORE_IMAGE_BASE_INSTALL_remove += "gtk+3-demo clutter-1.0-examples"

populate_vmlinux () {
    find ${STAGING_KERNEL_BUILDDIR} -iname "vmlinux*" -exec mv {} ${DEPLOY_DIR_IMAGE} \; || true
}

IMAGE_POSTPROCESS_COMMAND += "populate_vmlinux; "

install_aos () {
    if [ ! -z "${AOS_VIS_PACKAGE_DIR}" ];then
        opkg install ${AOS_VIS_PACKAGE_DIR}/ca-certificates_20170717-r0_all.ipk \
                     ${AOS_VIS_PACKAGE_DIR}/aos-vis_git-r0_aarch64.ipk
    fi
}

ROOTFS_POSTPROCESS_COMMAND += " install_aos; set_board_model; set_image_version; "
IMAGE_POSTPROCESS_COMMAND += " create_shared_links; "

IMAGE_FEATURES_append = " read-only-rootfs"

# Vars

SHARED_ROOTFS_DIR = "${XT_DIR_ABS_SHARED_ROOTFS_DOMD}/${IMAGE_BASENAME}"

# Dependencies

create_shared_links[dirs] = "${SHARED_ROOTFS_DIR}"

# Tasks

set_board_model() {
    install -d ${IMAGE_ROOTFS}/etc/aos

    echo "${BOARD_MODEL}" > ${IMAGE_ROOTFS}/etc/aos/board_model
}

set_image_version() {
    install -d ${IMAGE_ROOTFS}/etc/aos

    echo "VERSION=\"${DOMD_IMAGE_VERSION}\"" > ${IMAGE_ROOTFS}/etc/aos/version
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
