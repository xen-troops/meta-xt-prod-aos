DESCRIPTION = "Dom0 scripts used for AOS provisioning"

LICENSE = "CLOSED"

SRCREV = "${AUTOREV}"
SRC_URI = "git://git@gitpct.epam.com/epmd-aepr/aos_sdk.git;protocol=ssh"

S = "${WORKDIR}/git"

FILES_${PN} = " \
    ${libdir}/xen/scripts/aos-provisioning.step1.sh \
    ${libdir}/xen/scripts/aos-provisioning.step2.sh \
    ${sysconfdir}/aos/model_name.txt \
"

RDEPENDS_${PN} = "bash"

do_install() {
    install -d ${D}${base_prefix}${libdir}/xen/scripts
    install -m 0755 ${S}/aos-provisioning/aos-provisioning.step1.sh ${D}${base_prefix}${libdir}/xen/scripts
    install -m 0755 ${S}/aos-provisioning/aos-provisioning.step2.sh ${D}${base_prefix}${libdir}/xen/scripts
}
