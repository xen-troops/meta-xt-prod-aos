FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = " \
    file://aos-vis.service \
    file://aos_vis.cfg \
"

AOS_VIS_PLUGINS ?= " \
    plugins/vinadapter \
    plugins/boardmodeladapter \
    plugins/usersadapter \
    plugins/telemetryemulatoradapter \
    plugins/renesassimulatoradapter \
"

inherit systemd

SYSTEMD_SERVICE_${PN} = "aos-vis.service"

FILES_${PN} += " \
    ${sysconfdir}/aos/aos_vis.cfg \
    ${systemd_system_unitdir}/aos-vis.service \
    /etc/aos/vis/data/*.pem \
"

RDEPENDS_${PN} += " \
    ${@bb.utils.contains('AOS_VIS_PLUGINS', 'plugins/telemetryemulatoradapter', 'telemetry-emulator', '', d)} \
"

do_compile_prepend(){
    export GOCACHE=${WORKDIR}/cache
}

do_install_append() {
    if "${@bb.utils.contains('AOS_VIS_PLUGINS', 'plugins/telemetryemulatoradapter', 'true', 'false', d)}"; then
        if ! grep -q 'network-online.target telemetry-emulator.service' ${WORKDIR}/aos-vis.service ; then
            sed -i -e 's/network-online.target/network-online.target telemetry-emulator.service/g' ${WORKDIR}/aos-vis.service
        fi

        if ! grep -q 'ExecStartPre=/bin/sleep 1' ${WORKDIR}/aos-vis.service ; then
            sed -i -e '/ExecStart=/i ExecStartPre=/bin/sleep 1' ${WORKDIR}/aos-vis.service
        fi
    fi

    install -d ${D}${sysconfdir}/aos
    install -m 0644 ${WORKDIR}/aos_vis.cfg ${D}${sysconfdir}/aos

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/aos-vis.service ${D}${systemd_system_unitdir}/aos-vis.service

    install -d ${D}/etc/aos/vis/data
    install -m 0644 ${S}/src/${GO_IMPORT}/data/*.pem ${D}/etc/aos/vis/data
}
