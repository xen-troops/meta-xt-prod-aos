FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = "\
    file://eth0.network \
"

PACKAGECONFIG_append = " networkd"
PACKAGECONFIG_append = " iptc"
PACKAGECONFIG_append = " resolved"

USERADD_ERROR_DYNAMIC = "warn"

do_install_append() {
    install -d ${D}${sysconfdir}/systemd/network
    install -m 0644 ${WORKDIR}/*.network ${D}${sysconfdir}/systemd/network

    sed -i -e "s/\/lib\/systemd\/systemd-quotacheck/\/usr\/sbin\/quotacheck -avum/" \
          ${D}${systemd_unitdir}/system/systemd-quotacheck.service
}
