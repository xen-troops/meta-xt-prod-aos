FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = " \
    file://aos-servicemanager.service \
    file://aos_servicemanager.cfg \
    file://ipforwarding.conf \
    file://root_dev.conf \
    file://first-boot.service \
    file://first_boot.sh \
    file://rootCA.crt \
"

inherit systemd

RDEPENDS_${PN} += "\
    nodejs \
"

SYSTEMD_SERVICE_${PN} = " \
    first-boot.service \
"

FILES_${PN} += " \
    ${systemd_system_unitdir}/*.service \
    /var/aos/servicemanager/aos_servicemanager.cfg \
    ${sysconfdir}/sysctl.d/*.conf \
    ${sysconfdir}/tmpfiles.d/*.conf \
    ${datadir}/ca-certificates/aos/*.crt \
"

do_install_append() {
    install -d ${D}/var/aos/servicemanager
    install -m 0644 ${WORKDIR}/aos_servicemanager.cfg ${D}/var/aos/servicemanager

    install -d ${D}/var/aos/servicemanager/data/fcrypt

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/*.service ${D}${systemd_system_unitdir}

    install -d ${D}${sysconfdir}/sysctl.d
    install -m 0644 ${WORKDIR}/ipforwarding.conf ${D}${sysconfdir}/sysctl.d

    install -d ${D}${sysconfdir}/tmpfiles.d
    install -m 0644 ${WORKDIR}/root_dev.conf ${D}${sysconfdir}/tmpfiles.d

    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/first_boot.sh ${D}${bindir}

    install -d ${D}${datadir}/ca-certificates/aos
    install -m 0644 ${WORKDIR}/rootCA.crt ${D}${datadir}/ca-certificates/aos
}

VISSERVER = "192.168.0.1    wwwivi"
AOSCERTIFICATE = "aos/rootCA.crt"

pkg_postinst_${PN}() {
    if ! grep -q '${VISSERVER}' $D/etc/hosts ; then
        echo '${VISSERVER}' >> $D/etc/hosts
    fi

    if ! grep -q '${AOSCERTIFICATE}' $D/etc/ca-certificates.conf ; then
        echo '${AOSCERTIFICATE}' >> $D/etc/ca-certificates.conf
    fi

    sed -ie '/^\/dev\/root/ s/defaults/defaults,usrquota/' $D/etc/fstab
}
