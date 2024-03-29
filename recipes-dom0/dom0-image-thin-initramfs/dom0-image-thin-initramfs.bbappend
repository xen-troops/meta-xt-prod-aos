FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
FILESEXTRAPATHS_prepend := "${THISDIR}/../../recipes-domx:"

require recipes-domx/meta-xt-prod-domx/inc/xt_shared_env.inc

do_configure[depends] += "domd-image-minimal:do_domd_install_machine_overrides"
do_compile[depends] += "domd-image-minimal:do_${BB_DEFAULT_TASK}"

XT_GUESTS_BUILD ?= "domf"
XT_GUESTS_INSTALL ?= "domf"

python __anonymous () {
    guests = d.getVar('XT_GUESTS_BUILD', True).split()
    if "domf" in guests :
        d.appendVarFlag("do_compile", "depends", " domu-image-fusion:do_${BB_DEFAULT_TASK} ")
}

################################################################################
# Generic ARMv8
################################################################################
SRC_URI = "repo://github.com/xen-troops/manifests;protocol=https;branch=prod_aos-v${DOM0_IMAGE_VERSION};manifest=prod_aos/dom0.xml;scmdata=keep"

###############################################################################
# extra layers and files to be put after Yocto's do_unpack into inner builder
###############################################################################
# these will be populated into the inner build system on do_unpack_xt_extras
# N.B. xt_shared_env.inc MUST be listed AFTER meta-xt-prod-extra
XT_QUIRK_UNPACK_SRC_URI += " \
    file://meta-xt-prod-extra;subdir=repo \
    file://meta-xt-prod-domx;subdir=repo \
"

# these layers will be added to bblayers.conf on do_configure
XT_QUIRK_BB_ADD_LAYER += " \
    meta-xt-prod-extra \
    meta-xt-prod-domx \
"

XT_BB_LAYERS_FILE = "meta-xt-prod-extra/doc/bblayers.conf.dom0-image-minimal-initramfs"
XT_BB_LOCAL_CONF_FILE = "meta-xt-prod-extra/doc/local.conf.dom0-image-minimal-initramfs"

XT_BB_IMAGE_TARGET = "core-image-thin-initramfs"

add_to_local_conf() {
    local local_conf="${S}/build/conf/local.conf"

    cd ${S}

    # hvc0 is not a serial console, so is not processes properly by a modern
    # start_getty script which is installed for sysvinit based systems.
    # Instead a distro feature xen should be enabled in a configuration, so a
    # direct call to getty with hvc0 is installed into inittab by meta-viltualization.
    base_update_conf_value ${local_conf} SERIAL_CONSOLE ""

    base_update_conf_value ${local_conf} PREFERRED_VERSION_xen "4.12.0+git\%"

    base_update_conf_value ${local_conf} XT_GUESTS_INSTALL "${XT_GUESTS_INSTALL}"

    # set update variables
    base_update_conf_value ${local_conf} DOM0_IMAGE_VERSION "${DOM0_IMAGE_VERSION}"
}

python do_configure_append() {
    bb.build.exec_func("add_to_local_conf", d)
}

