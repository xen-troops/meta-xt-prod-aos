SUMMARY = "Set of files to run a Fusion domain"
DESCRIPTION = "A config file, kernel, dtb and scripts for a Fusion domain"

PV = "0.1"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

inherit externalsrc systemd

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

RDEPENDS_${PN} = "backend-ready"

FILES_${PN} += " \
    ${sysconfdir}/xen/domf.cfg \
    ${libdir}/xen/boot/domf.dtb \
    ${libdir}/xen/boot/linux-domf \
    ${systemd_unitdir}/system/domf.service \
    ${libdir}/xen/bin/domf-set-root \
    ${libdir}/xen/boot/domf-uInitramfs.cpio.gz \
"

# It is used a lot in the do_install, so variable will be handy
CFG_FILE="${D}${sysconfdir}/xen/domf.cfg"

SRC_URI = "\
    file://${XT_DOMU_CONFIG_NAME} \
    file://domf.service \
    file://domf-set-root \
"

SYSTEMD_SERVICE_${PN} = "domf.service"

do_install() {
    install -d ${D}${sysconfdir}/xen
    install -d ${D}${libdir}/xen/boot
    install -m 0644 ${WORKDIR}/${XT_DOMF_CONFIG_NAME} ${D}${sysconfdir}/xen/domf.cfg
    install -m 0644 ${S}/${XT_DOMU_DTB_NAME} ${D}${libdir}/xen/boot/domf.dtb
    install -m 0644 ${S}/Image ${D}${libdir}/xen/boot/linux-domf
    install -m 0644 ${S}/uInitramfs.cpio.gz  ${D}${libdir}/xen/boot/domf-uInitramfs.cpio.gz

    install -d ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/domf.service ${D}${systemd_unitdir}/system/


#    cat ${WORKDIR}/domf-vdevices.cfg >> ${CFG_FILE}

    if ${@bb.utils.contains('DISTRO_FEATURES', 'virtio', 'true', 'false', d)}; then
        sed -i 's/3, xvda1/3, xvda1, virtio/' ${CFG_FILE}

        # Update root by changing xvda1 to vda
        sed -i 's/root=\/dev\/xvda1/root=\/dev\/vda/' ${CFG_FILE}

        # Update GUEST_DEPENDENCIES by adding virtio-disk after sndbe
        echo "[Unit]" >> ${D}${systemd_unitdir}/system/domu.service
        echo "Requires=backend-ready@virtio.service" >> ${D}${systemd_unitdir}/system/domf.service
        echo "After=backend-ready@virtio.service" >> ${D}${systemd_unitdir}/system/domf.service
    fi

    # Install domu-set-root script
    install -d ${D}${libdir}/xen/bin
    install -m 0744 ${WORKDIR}/domf-set-root ${D}${libdir}/xen/bin

    # Call domu-set-root script
    echo "[Service]" >> ${D}${systemd_unitdir}/system/domf.service
    echo "ExecStartPre=${libdir}/xen/bin/domf-set-root" >> ${D}${systemd_unitdir}/system/domf.service

    # Fixup a number of PCPUs the VCPUs of DomF must run on
    sed -i "s/DOMF_ALLOWED_PCPUS/4-7/g" ${D}${sysconfdir}/xen/domf.cfg 
}

