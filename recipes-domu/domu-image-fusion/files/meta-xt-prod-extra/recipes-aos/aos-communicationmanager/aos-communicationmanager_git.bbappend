FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = " \
    file://aos_communicationmanager.cfg \
    file://aos-communicationmanager.service \
"

inherit systemd

SYSTEMD_SERVICE_${PN} = "aos-communicationmanager.service"

MIGRATION_SCRIPTS_PATH = "/usr/share/communicationmanager/migration"

FILES_${PN} += " \
    ${sysconfdir}/aos/aos_communicationmanager.cfg \
    ${systemd_system_unitdir}/*.service \
    ${MIGRATION_SCRIPTS_PATH} \
"

do_install_append() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/*.service ${D}${systemd_system_unitdir}

    install -d ${D}${sysconfdir}/aos
    install -m 0644 ${WORKDIR}/aos_communicationmanager.cfg ${D}${sysconfdir}/aos

    install -d ${D}/var/aos/communicationmanager

    install -d ${D}${MIGRATION_SCRIPTS_PATH}
    source_migration_path="/src/aos_communicationmanager/database/migration"
    if [ -d ${S}${source_migration_path} ]; then
        install -m 0644 ${S}${source_migration_path}/* ${D}${MIGRATION_SCRIPTS_PATH}
    fi
}

pkg_postinst_${PN}() {
    # Add aoscm to /etc/hosts
    if ! grep -q 'aoscm' $D${sysconfdir}/hosts ; then
        echo '127.0.0.1	aoscm' >> $D${sysconfdir}/hosts
    fi
}
