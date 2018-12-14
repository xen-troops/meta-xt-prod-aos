FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

VISSERVER = "192.168.0.1    wwwivi"

SRC_URI_append = " \
    file://aos-servicemanager.service \
    file://aos_servicemanager.cfg \
    file://ipforwarding.conf \
"

inherit systemd

SYSTEMD_SERVICE_${PN} = "aos-servicemanager.service"

FILES_${PN} += " \
    ${systemd_system_unitdir}/*.service \
    /var/aos/servicemanager/aos_servicemanager.cfg \
    ${sysconfdir}/sysctl.d/*.conf \
"

do_install_append() {
    install -d ${D}/var/aos/servicemanager
    install -m 0644 ${WORKDIR}/aos_servicemanager.cfg ${D}/var/aos/servicemanager

    install -d ${D}/var/aos/servicemanager/fcrypt

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/*.service ${D}${systemd_system_unitdir}

    install -d ${D}${sysconfdir}/sysctl.d
    install -m 0644 ${WORKDIR}/*.conf ${D}${sysconfdir}/sysctl.d
}

pkg_postinst_${PN}() {
    if ! grep -q '${VISSERVER}' $D/etc/hosts ; then
        echo '${VISSERVER}' >> $D/etc/hosts
    fi

    sed -ie '/^\/dev\/root/ s/defaults/defaults,usrquota/' $D/etc/fstab
}
