FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = "\
    file://aos-vis.service \
    file://visconfig_telemetryemulator.json \
    file://visconfig_renesassimulator.json \
"

AOS_VIS_PLUGINS ?= "\
    telemetryemulatoradapter \
"

PLUGINS += "\
    storageadapter \
    ${AOS_VIS_PLUGINS} \
"

inherit systemd

SYSTEMD_SERVICE_${PN} = "aos-vis.service"

HOST_CC_ARCH = ""

FILES_${PN} += " \
    ${systemd_system_unitdir}/aos-vis.service \
    /var/aos/vis/data/*.pem \
    /var/aos/vis/visconfig.json \
"

do_install_append() {
    install -d ${D}/var/aos/vis

    if "${@bb.utils.contains('AOS_VIS_PLUGINS', 'telemetryemulatoradapter', 'true', 'false', d)}";then
        install -m 0644 ${WORKDIR}/visconfig_telemetryemulator.json ${D}/var/aos/vis/visconfig.json
    fi

    if "${@bb.utils.contains('AOS_VIS_PLUGINS', 'renesassimulatoradapter', 'true', 'false', d)}";then
        install -m 0644 ${WORKDIR}/visconfig_renesassimulator.json ${D}/var/aos/vis/visconfig.json
    fi

    install -d ${D}/var/aos/vis/data
    install -m 0644 ${S}/src/${GO_IMPORT}/data/*.pem ${D}/var/aos/vis/data

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/*.service ${D}${systemd_system_unitdir}
}
