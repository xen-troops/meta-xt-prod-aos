FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

VISSERVER = "192.168.0.1    wwwivi"

SRC_URI_append = " \
    file://aos-servicemanager.service \
    file://aos_servicemanager.cfg \
    file://ipforwarding.conf \
    file://root_dev.conf \
    file://first-boot.service \
    file://first_boot.sh \
"

inherit systemd

SYSTEMD_SERVICE_${PN} = " \
    first-boot.service \
"

FILES_${PN} += " \
    ${systemd_system_unitdir}/*.service \
    /var/aos/servicemanager/aos_servicemanager.cfg \
    ${sysconfdir}/sysctl.d/*.conf \
    ${sysconfdir}/tmpfiles.d/*.conf \
"

do_install_append() {
    install -d ${D}/var/aos/servicemanager
    install -m 0644 ${WORKDIR}/aos_servicemanager.cfg ${D}/var/aos/servicemanager

    install -d ${D}/var/aos/servicemanager/fcrypt

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/*.service ${D}${systemd_system_unitdir}

    install -d ${D}${sysconfdir}/sysctl.d
    install -m 0644 ${WORKDIR}/ipforwarding.conf ${D}${sysconfdir}/sysctl.d

    install -d ${D}${sysconfdir}/tmpfiles.d
    install -m 0644 ${WORKDIR}/root_dev.conf ${D}${sysconfdir}/tmpfiles.d

    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/first_boot.sh ${D}${bindir}
}

pkg_postinst_${PN}() {
    if ! grep -q '${VISSERVER}' $D/etc/hosts ; then
        echo '${VISSERVER}' >> $D/etc/hosts
    fi

    sed -ie '/^\/dev\/root/ s/defaults/defaults,usrquota/' $D/etc/fstab
}
