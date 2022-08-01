FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = " \
    file://ip_forward.conf \
"

PACKAGECONFIG_append = " networkd"
PACKAGECONFIG_append = " iptc"
PACKAGECONFIG_append = " resolved"

USERADD_ERROR_DYNAMIC = "warn"

quotacheck_srv = "systemd-quotacheck.service"
quotaon_srv = "quotaon.service"

do_install_append() {
    install -m 0644 ${WORKDIR}/ip_forward.conf ${D}${sysconfdir}/tmpfiles.d/

    install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants

    sed -i -e "s/\/lib\/systemd\/systemd-quotacheck/\/usr\/sbin\/quotacheck -avum/" \
         ${D}${systemd_unitdir}/system/${quotacheck_srv}

    ln -sf ${systemd_unitdir}/system/${quotacheck_srv} ${D}${sysconfdir}/systemd/system/multi-user.target.wants/${quotacheck_srv}
    ln -sf ${systemd_unitdir}/system/${quotaon_srv} ${D}${sysconfdir}/systemd/system/multi-user.target.wants/${quotaon_srv}
}

