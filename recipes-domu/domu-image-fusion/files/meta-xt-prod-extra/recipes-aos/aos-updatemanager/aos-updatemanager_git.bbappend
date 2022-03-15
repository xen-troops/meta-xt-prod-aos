FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = " \
    file://aos-updatemanager.service \
    file://aos-reboot.service \
    file://aos_updatemanager.cfg \
"

AOS_UM_UPDATE_MODULES ?= " \
    updatemodules/overlaysystemd \
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
    ${systemd_system_unitdir}/aos-updatemanager.service \
    ${systemd_system_unitdir}/aos-reboot.service \
    ${MIGRATION_SCRIPTS_PATH} \
"

do_install_append() {
    install -d ${D}${sysconfdir}/aos
    install -m 0644 ${WORKDIR}/aos_updatemanager.cfg ${D}${sysconfdir}/aos

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/aos-updatemanager.service ${D}${systemd_system_unitdir}/aos-updatemanager.service
    install -m 0644 ${WORKDIR}/aos-reboot.service ${D}${systemd_system_unitdir}/aos-reboot.service

    install -d ${D}/var/aos/updatemanager

    install -d ${D}${MIGRATION_SCRIPTS_PATH}
    source_migration_path="src/${GO_OMPORT}/database/migration"
    if [ -d ${S}/${source_migration_path} ]; then
        install -m 0644 ${S}/${source_migration_path}/* ${D}${MIGRATION_SCRIPTS_PATH}
    fi
}
