FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

BRANCH = "master"

SRC_URI_append = "\
    file://aos-iamanager.service \
    file://aos_iamanager.cfg \
    file://finish.sh \
    file://aos.target \
    file://rootCA.pem \
"

AOS_IAM_CERT_MODULES = "\
    certhandler/modules/swmodule \
"

AOS_IAM_IDENT_MODULES = "\
    identhandler/modules/visidentifier \
"

inherit systemd

SYSTEMD_SERVICE_${PN} = "aos-iamanager.service aos.target"

FILES_${PN} += " \
    ${sysconfdir}/aos/aos_iamanager.cfg \
    ${systemd_system_unitdir}/aos-iamanager.service \
    ${systemd_system_unitdir}/aos.target \
    /usr/bin/finish.sh \
"

do_compile_prepend(){
    export GOCACHE=${WORKDIR}/cache
}


do_install_append() {
    install -d ${D}${sysconfdir}/aos
    install -m 0644 ${WORKDIR}/aos_iamanager.cfg ${D}${sysconfdir}/aos

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/aos-iamanager.service ${D}${systemd_system_unitdir}/aos-iamanager.service
    install -m 0644 ${WORKDIR}/aos.target ${D}${systemd_system_unitdir}/aos.target

    install -d ${D}/var/aos/iamanager
    install -m 0755 ${WORKDIR}/finish.sh ${D}/usr/bin/finish.sh

    install -d ${D}${sysconfdir}/ssl/certs
    install -m 0644 ${WORKDIR}/rootCA.pem ${D}${sysconfdir}/ssl/certs/
}

pkg_postinst_${PN}() {
    # Add wwwivi to /etc/hosts
    if ! grep -q 'wwwivi' $D${sysconfdir}/hosts ; then
        echo '192.168.0.1	wwwivi' >> $D${sysconfdir}/hosts
    fi

    # Add aossm to /etc/hosts
    if ! grep -q 'aossm' $D${sysconfdir}/hosts ; then
        echo '192.168.0.3	aossm' >> $D${sysconfdir}/hosts
    fi
}
