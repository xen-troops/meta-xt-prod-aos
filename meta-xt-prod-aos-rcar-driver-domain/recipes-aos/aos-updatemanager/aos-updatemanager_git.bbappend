FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
FILESEXTRAPATHS_prepend_cetibox := "${THISDIR}/files/cetibox:"

SRC_URI_append = " \
    file://aos-updatemanager.service \
    file://aos-reboot.service \
    file://aos_updatemanager.cfg \
    file://rootCA.pem \
"

AOS_UM_UPDATE_MODULES ?= " \
    updatemodules/overlayxenstore \
    updatemodules/ubootdualpart \
"

AOS_UM_UPDATE_MODULES_cetibox ?= " \
    updatemodules/overlayxenstore \
    updatemodules/ubootdualpart \
    updatemodules/sshmodule \
"

inherit systemd

SYSTEMD_SERVICE_${PN} = " \
    aos-updatemanager.service \
"

MIGRATION_SCRIPTS_PATH = "/usr/share/updatemanager/migration"

DEPENDS_append = " \
    pkgconfig-native \
    systemd \
    efivar \
"

FILES_${PN} += " \
    ${sysconfdir}/aos/aos_updatemanager.cfg \
    ${sysconfdir}/ssl/certs/*.pem \
    ${systemd_system_unitdir}/aos-updatemanager.service \
    ${systemd_system_unitdir}/aos-reboot.service \
    ${MIGRATION_SCRIPTS_PATH} \
"

do_compile_prepend(){
    export GOCACHE=${WORKDIR}/cache
}

do_install_append() {
    install -d ${D}${sysconfdir}/aos
    install -m 0644 ${WORKDIR}/aos_updatemanager.cfg ${D}${sysconfdir}/aos

    install -d ${D}${sysconfdir}/ssl/certs
    install -m 0644 ${WORKDIR}/rootCA.pem ${D}${sysconfdir}/ssl/certs/

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/aos-updatemanager.service ${D}${systemd_system_unitdir}/aos-updatemanager.service
    install -m 0644 ${WORKDIR}/aos-reboot.service ${D}${systemd_system_unitdir}/aos-reboot.service

    install -d ${D}/var/aos/updatemanager

    install -d ${D}${MIGRATION_SCRIPTS_PATH}
    source_migration_path="src/aos_updatemanager/database/migration"
    if [ -d ${S}/${source_migration_path} ]; then
        install -m 0644 ${S}/${source_migration_path}/* ${D}${MIGRATION_SCRIPTS_PATH}
    fi
}

pkg_postinst_${PN}() {
    # Add aossm to /etc/hosts
    if ! grep -q 'aoscm' $D${sysconfdir}/hosts ; then
        echo '192.168.0.3	aoscm' >> $D${sysconfdir}/hosts
    fi

    # Add aosiam to /etc/hosts
    if ! grep -q 'aosiam' $D${sysconfdir}/hosts ; then
        echo '192.168.0.3	aosiam' >> $D${sysconfdir}/hosts
    fi
}
