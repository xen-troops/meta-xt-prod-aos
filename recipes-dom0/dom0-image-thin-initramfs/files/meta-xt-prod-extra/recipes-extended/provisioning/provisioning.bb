DESCRIPTION = "Dom0 scripts used for AOS provisioning"

require inc/xt_shared_env.inc

LICENSE = "CLOSED"

SRCREV = "${AUTOREV}"
SRC_URI = "git://git@gitpct.epam.com/epmd-aepr/aos_sdk.git;protocol=ssh"

S = "${WORKDIR}/git"

FILES_${PN} = " \
    ${base_prefix}${XT_DIR_ABS_ROOTFS_SCRIPTS}/aos-provisioning.step1.sh \
    ${base_prefix}${XT_DIR_ABS_ROOTFS_SCRIPTS}/aos-provisioning.step2.sh \
    ${sysconfdir}/aos/model_name.txt \
"

RDEPENDS_${PN} = "bash"

# content of /etc/aos/model_name.txt for provisioning
DOM0_MODEL_NAME_salvator-x-m3-xt       = "salvator-x-m3"
DOM0_MODEL_NAME_salvator-x-h3-xt       = "salvator-x-h3"
DOM0_MODEL_NAME_salvator-xs-h3-xt      = "salvator-xs-h3"
DOM0_MODEL_NAME_salvator-x-h3-4x2g-xt  = "salvator-x-h3-4x2g"
DOM0_MODEL_NAME_salvator-xs-h3-4x2g-xt = "salvator-xs-h3-4x2g"
DOM0_MODEL_NAME_h3ulcb-4x2g-xt         = "h3ulcb-4x2g"
DOM0_MODEL_NAME_h3ulcb-4x2g-kf-xt      = "h3ulcb-4x2g-kf"
DOM0_MODEL_NAME_h3ulcb-cb-xt           = "h3ulcb-cb"

do_install() {
    install -d ${D}${base_prefix}${XT_DIR_ABS_ROOTFS_SCRIPTS}
    install -m 0755 ${S}/aos-provisioning/aos-provisioning.step1.sh ${D}${base_prefix}${XT_DIR_ABS_ROOTFS_SCRIPTS}
    install -m 0755 ${S}/aos-provisioning/aos-provisioning.step2.sh ${D}${base_prefix}${XT_DIR_ABS_ROOTFS_SCRIPTS}

    install -d ${D}${sysconfdir}/aos
    echo ${DOM0_MODEL_NAME} > ${D}${sysconfdir}/aos/model_name.txt
}
