FILESEXTRAPATHS_prepend := "${THISDIR}/optee-client:"

SRCREV = "06e1b32f6a7028e039c625b07cfc25fda0c17d53"
PV = "git${SRCPV}"

EXTRA_OEMAKE = " \
    RPMB_EMU=0 \
    CFG_TEE_FS_PARENT_PATH=/var/aos/crypt/optee \
"

do_install_append() {
    install -D -p -m 0644 ${S}/out/export/usr/lib/libckteec.so.0.1 ${D}${libdir}/libckteec.so.0.1
    lnr ${D}${libdir}/libckteec.so.0.1 ${D}${libdir}/libckteec.so
    lnr ${D}${libdir}/libckteec.so.0.1 ${D}${libdir}/libckteec.so.0
}
