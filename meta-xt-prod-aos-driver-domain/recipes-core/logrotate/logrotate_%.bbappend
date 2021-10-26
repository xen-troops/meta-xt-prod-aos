FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = "\
    file://xen \
    file://messages \
"

FILES_${PN} += " \
    ${sysconfdir}/logrotate.d/* \
"

do_install_append () {
    install -d 755 ${D}/${sysconfdir}/logrotate.d/

    install -m 644 ${WORKDIR}/xen ${D}/${sysconfdir}/logrotate.d/
    install -m 644 ${WORKDIR}/messages ${D}/${sysconfdir}/logrotate.d/
}