FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
FILESEXTRAPATHS_prepend := "${THISDIR}/../../recipes-domx:"

require recipes-domx/meta-xt-prod-domx/inc/xt_shared_env.inc

XT_PRODUCT_NAME ?= "prod-aos"

python __anonymous () {
    product_name = d.getVar('XT_PRODUCT_NAME', True)
    folder_name = product_name.replace("-", "_")
    d.setVar('XT_MANIFEST_FOLDER', folder_name)
    if product_name == "prod-aos":
        d.appendVar("XT_QUIRK_BB_ADD_LAYER", "meta-aos")
}

SRC_URI = " \
    repo://github.com/iusyk/manifests;protocol=https;branch=feature/aos-rel-7.0;manifest=${XT_MANIFEST_FOLDER}/domd.xml;scmdata=keep \
"

XT_QUIRK_UNPACK_SRC_URI += " \
    file://meta-xt-prod-extra;subdir=repo \
    file://meta-xt-prod-domx;subdir=repo \
"

XT_QUIRK_BB_ADD_LAYER += " \
    meta-xt-prod-extra \
    meta-xt-prod-domx \
"

################################################################################
# Renesas R-Car H3ULCB ES3.0 8GB Kingfisher
################################################################################
XT_QUIRK_BB_ADD_LAYER_append_h3ulcb-4x2g-kf = " \
    meta-rcar/meta-rcar-gen3-adas \
"

configure_versions_kingfisher() {
    local local_conf="${S}/build/conf/local.conf"

    cd ${S}
    #FIXME: patch ADAS: do not use network setup as we provide our own
    base_add_conf_value ${local_conf} BBMASK "meta-rcar-gen3-adas/recipes-core/systemd"
    # Remove development tools from the image
    base_add_conf_value ${local_conf} IMAGE_INSTALL_remove " strace eglibc-utils ldd rsync gdbserver dropbear opkg git subversion nano cmake vim"
    base_add_conf_value ${local_conf} DISTRO_FEATURES_remove " opencv-sdk"
    # Do not enable surroundview which cannot be used
    base_add_conf_value ${local_conf} DISTRO_FEATURES_remove " surroundview"
}

python do_configure_append_h3ulcb-4x2g-kf() {
    bb.build.exec_func("configure_versions_kingfisher", d)
}

XT_BB_IMAGE_TARGET = "core-image-minimal"

# Dom0 is a generic ARMv8 machine w/o machine overrides,
# but still needs to know which system we are building,
# e.g. Salvator-X M3 or H3, for instance
# So, we provide machine overrides from this build the domain.
# The same is true for Android build.
addtask domd_install_machine_overrides after do_configure before do_compile
python do_domd_install_machine_overrides() {
    bb.debug(1, "Installing machine overrides")

    d.setVar('XT_BB_CMDLINE', "-f domd-install-machine-overrides")
    bb.build.exec_func("build_yocto_exec_bitbake", d)
}

################################################################################
# Renesas R-Car
################################################################################
XT_QUIRK_PATCH_SRC_URI_rcar = " \
    file://0001-rcar-gen3-arm-trusted-firmware-Allow-to-add-more-bui.patch;patchdir=meta-renesas \
    file://0001-copyscript-Set-GFX-Library-List-to-empty-string.patch;patchdir=meta-renesas \
    file://0001-recipes-kernel-Load-multimedia-related-modules-autom.patch;patchdir=meta-renesas \
    file://0001-armtf-Clarify-check-for-the-h3ulcb-based-machines-in.patch;patchdir=meta-renesas \
    file://0001-Update-meta-rcar-for-Yv510.patch;patchdir=meta-renesas \
"

XT_BB_LAYERS_FILE_rcar = "meta-xt-prod-extra/doc/bblayers.conf.rcar-domd-image-minimal"

configure_versions_rcar() {
    local local_conf="${S}/build/conf/local.conf"

    cd ${S}
    base_update_conf_value ${local_conf} PREFERRED_VERSION_xen "4.16.0+git\%"
    base_update_conf_value ${local_conf} PREFERRED_VERSION_u-boot_rcar "v2020.10\%"

    # HACK: force ipk instead of rpm b/c it makes troubles to PVR UM build otherwise
    base_update_conf_value ${local_conf} PACKAGE_CLASSES "package_ipk"

    # FIXME: normally bitbake fails with error if there are bbappends w/o recipes
    # which is the case for agl-demo-platform's recipe-platform while building
    # agl-image-weston: due to AGL's Yocto configuration recipe-platform is only
    # added to bblayers if building agl-demo-platform, thus making bitbake to
    # fail if this recipe is absent. Workaround this by allowing bbappends without
    # corresponding recipies.
    base_update_conf_value ${local_conf} BB_DANGLINGAPPENDS_WARNONLY "yes"

    # override console specified by default by the meta-rcar-gen3
    # to be hypervisor's one
    base_update_conf_value ${local_conf} SERIAL_CONSOLE "115200 hvc0"

    # set default timezone to Las Vegas
    base_update_conf_value ${local_conf} DEFAULT_TIMEZONE "US/Pacific"

    base_update_conf_value ${local_conf} XT_GUESTS_INSTALL "${XT_GUESTS_INSTALL}"

    # Remove multimedia and graphic support
    base_set_conf_value ${local_conf} DISTRO_FEATURES_remove "ivi-shell opengl wayland vulkan pulseaudio"

    if [ ! -z "${AOS_VIS_PLUGINS}" ];then
        base_update_conf_value ${local_conf} AOS_VIS_PLUGINS "${AOS_VIS_PLUGINS}"
    fi

    if [ ! -z "${AOS_VIS_PACKAGE_DIR}" ];then
        base_update_conf_value ${local_conf} AOS_VIS_PACKAGE_DIR "${AOS_VIS_PACKAGE_DIR}"
    fi

    # Only Kingfisher variants have WiFi and bluetooth
    if echo "${MACHINEOVERRIDES}" | grep -qiv "kingfisher"; then
        base_add_conf_value ${local_conf} DISTRO_FEATURES_remove "wifi bluetooth"
    fi

    base_add_conf_value ${local_conf} DISTRO_FEATURES_append " systemd"
    base_add_conf_value ${local_conf} BBMASK "meta-arm/meta-arm/recipes-security/optee/optee-os"
    base_add_conf_value ${local_conf} BBMASK "meta-renesas/meta-rcar-gen3/recipes-bsp/optee/optee-os"

    # set update variables
    base_update_conf_value ${local_conf} DOMD_IMAGE_VERSION "${DOMD_IMAGE_VERSION}"
    base_update_conf_value ${local_conf} BOARD_MODEL "${BOARD_MODEL}"
}

python do_configure_append_rcar() {
    bb.build.exec_func("configure_versions_rcar", d)
}

do_install_append () {
    local LAYERDIR=${TOPDIR}/../meta-xt-prod-aos
    find ${LAYERDIR}/doc -iname "u-boot-env*" -exec cp -f {} ${DEPLOY_DIR} \;
    find ${LAYERDIR}/doc -iname "mk_sdcard_image.sh" -exec cp -f {} ${DEPLOY_DIR} \;
    find ${LAYERDIR}/doc -iname "boardconfig.json" -exec cp -f {} ${DEPLOY_DIR} \;

    find ${DEPLOY_DIR}/${PN}/ipk/aarch64 -iname "aos-vis_git*" -exec cp -f {} ${DEPLOY_DIR}/domd-image-minimal/images/${MACHINE}-xt \; || true
    find ${DEPLOY_DIR}/${PN}/ipk/all -iname "ca-certificates_*" -exec cp -f {} ${DEPLOY_DIR}/domd-image-minimal/images/${MACHINE}-xt \; || true
}
