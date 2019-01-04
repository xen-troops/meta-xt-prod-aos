FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

<<<<<<< HEAD
=======
VISSERVER = "192.168.0.1    wwwivi"

>>>>>>> 7381760... domf: add tmpfiles.d config to create /dev/root symlink
SRC_URI_append = " \
    file://aos-servicemanager.service \
    file://aos_servicemanager.cfg \
    file://ipforwarding.conf \
    file://root_dev.conf \
<<<<<<< HEAD
    file://first-boot.service \
    file://first_boot.sh \
    file://rootCA.crt \
=======
>>>>>>> 7381760... domf: add tmpfiles.d config to create /dev/root symlink
"

inherit systemd

<<<<<<< HEAD
RDEPENDS_${PN} += "\
    nodejs \
"

SYSTEMD_SERVICE_${PN} = " \
    first-boot.service \
"
=======
SYSTEMD_SERVICE_${PN} = "aos-servicemanager.service"
>>>>>>> 7381760... domf: add tmpfiles.d config to create /dev/root symlink

FILES_${PN} += " \
    ${systemd_system_unitdir}/*.service \
    /var/aos/servicemanager/aos_servicemanager.cfg \
    ${sysconfdir}/sysctl.d/*.conf \
    ${sysconfdir}/tmpfiles.d/*.conf \
<<<<<<< HEAD
    ${datadir}/ca-certificates/aos/*.crt \
=======
>>>>>>> 7381760... domf: add tmpfiles.d config to create /dev/root symlink
"

do_install_append() {
    install -d ${D}/var/aos/servicemanager
    install -m 0644 ${WORKDIR}/aos_servicemanager.cfg ${D}/var/aos/servicemanager

<<<<<<< HEAD
    install -d ${D}/var/aos/servicemanager/data/fcrypt
=======
    install -d ${D}/var/aos/servicemanager/fcrypt
>>>>>>> 7381760... domf: add tmpfiles.d config to create /dev/root symlink

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/*.service ${D}${systemd_system_unitdir}

    install -d ${D}${sysconfdir}/sysctl.d
    install -m 0644 ${WORKDIR}/ipforwarding.conf ${D}${sysconfdir}/sysctl.d

    install -d ${D}${sysconfdir}/tmpfiles.d
    install -m 0644 ${WORKDIR}/root_dev.conf ${D}${sysconfdir}/tmpfiles.d
<<<<<<< HEAD

    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/first_boot.sh ${D}${bindir}

    install -d ${D}${datadir}/ca-certificates/aos
    install -m 0644 ${WORKDIR}/rootCA.crt ${D}${datadir}/ca-certificates/aos
}

VISSERVER = "192.168.0.1    wwwivi"
AOSCERTIFICATE = "aos/rootCA.crt"

=======
}

>>>>>>> 7381760... domf: add tmpfiles.d config to create /dev/root symlink
pkg_postinst_${PN}() {
    if ! grep -q '${VISSERVER}' $D/etc/hosts ; then
        echo '${VISSERVER}' >> $D/etc/hosts
    fi

<<<<<<< HEAD
    if ! grep -q '${AOSCERTIFICATE}' $D/etc/ca-certificates.conf ; then
        echo '${AOSCERTIFICATE}' >> $D/etc/ca-certificates.conf
    fi

=======
>>>>>>> 7381760... domf: add tmpfiles.d config to create /dev/root symlink
    sed -ie '/^\/dev\/root/ s/defaults/defaults,usrquota/' $D/etc/fstab
}
