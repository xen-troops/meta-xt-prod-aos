FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = " \
    file://ip_forward.conf \
    file://eth0.network \
"

SRC_URI_append_cetibox = " \
    file://eth0.1.netdev \
    file://eth0.1.network \
    file://eth0.2.netdev \
    file://eth0.2.network \
"

FILES_${PN} += "${sysconfdir}/systemd/network/*"

PACKAGECONFIG_append = " networkd"
PACKAGECONFIG_append = " iptc"
PACKAGECONFIG_append = " resolved"

USERADD_ERROR_DYNAMIC = "warn"

do_install_append() {
    install -m 0644 ${WORKDIR}/ip_forward.conf ${D}${sysconfdir}/tmpfiles.d/

    install -d ${D}${sysconfdir}/systemd/network/
    install -m 0644 ${WORKDIR}/eth0.network  ${D}${sysconfdir}/systemd/network/
}

do_install_append_cetibox() {
    install -m 0644 ${WORKDIR}/eth0.1.netdev  ${D}${sysconfdir}/systemd/network/
    install -m 0644 ${WORKDIR}/eth0.1.network  ${D}${sysconfdir}/systemd/network/
    install -m 0644 ${WORKDIR}/eth0.2.netdev  ${D}${sysconfdir}/systemd/network/
    install -m 0644 ${WORKDIR}/eth0.2.network  ${D}${sysconfdir}/systemd/network/
}
