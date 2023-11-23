FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = " \
    file://aos-iamanager.service \
    file://aos_iamanager.cfg \
    file://finish.sh \
"

AOS_IAM_CERT_MODULES = " \
    certhandler/modules/swmodule \
    certhandler/modules/pkcs11module \
"

AOS_IAM_IDENT_MODULES = " \
    identhandler/modules/visidentifier \
"

inherit systemd

SYSTEMD_SERVICE_${PN} = "aos-iamanager.service"

FILES_${PN} += " \
    ${sysconfdir}/aos/aos_iamanager.cfg \
    ${systemd_system_unitdir}/aos-iamanager.service \
    /usr/bin/finish.sh \
"

RDEPENDS_${PN} += " \
    opensc \
    optee-os \
    optee-client \
"

do_compile_prepend(){
    export GOCACHE=${WORKDIR}/cache
}


do_install_append() {
    install -d ${D}${sysconfdir}/aos
    install -m 0644 ${WORKDIR}/aos_iamanager.cfg ${D}${sysconfdir}/aos

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/aos-iamanager.service ${D}${systemd_system_unitdir}/aos-iamanager.service

    install -d ${D}/var/aos/iamanager
    install -m 0755 ${WORKDIR}/finish.sh ${D}/usr/bin/finish.sh
}

pkg_postinst_${PN}() {
    # Add wwwivi to /etc/hosts
    if ! grep -q 'wwwivi' $D${sysconfdir}/hosts ; then
        echo '192.168.0.1	wwwivi' >> $D${sysconfdir}/hosts
    fi

    # Add aosiam to /etc/hosts
    if ! grep -q 'aosiam' $D${sysconfdir}/hosts ; then
        echo '192.168.0.3	aosiam' >> $D${sysconfdir}/hosts
    fi
}
