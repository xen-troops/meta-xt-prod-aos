FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://depend.conf \
"

FILES_${PN} += " \
    ${sysconfdir}/systemd/system/dnsmasq.service.d/depend.conf \
"

do_install_append() {
    # Make dnsmasq listen only on bridge interface
    echo "interface=xenbr0" >> ${D}${sysconfdir}/dnsmasq.conf

    # Define DHCP leases range. Upper part of subnet can be used
    # for static configuration.
    echo "dhcp-range=xenbr0,192.168.0.2,192.168.0.150,12h" >> ${D}${sysconfdir}/dnsmasq.conf

    # Configure addresses for DomF and DomA. Mac addresses
    # are the same as in /xt/conf/*.conf
    echo "dhcp-host=08:00:27:ff:cb:cd,domf,192.168.0.3,infinite" >> ${D}${sysconfdir}/dnsmasq.conf
    echo "dhcp-host=08:00:27:ff:cb:ce,doma,192.168.0.4,infinite" >> ${D}${sysconfdir}/dnsmasq.conf

    # Use resolve.conf provided by systemd-resolved
    echo "resolv-file=/run/systemd/resolve/resolv.conf" >> ${D}${sysconfdir}/dnsmasq.conf

    # Add actual dependencies
    install -d ${D}${sysconfdir}/systemd/system/dnsmasq.service.d
    install -m 0644 ${WORKDIR}/depend.conf ${D}${sysconfdir}/systemd/system/dnsmasq.service.d/
}

do_install_append_cetibox() {
    # Cetibox has two physical eth connectors: uplink (eth0.1) and downlink (eth0.2)
    # device on downlink expects DHCP from us, so we have to set
    # dnsmasq accordingly
    echo "interface=eth0.2" >> ${D}${sysconfdir}/dnsmasq.conf

    # Define DHCP leases range. Upper part of subnet can be used
    # for static configuration.
    echo "dhcp-range=eth0.2,10.0.0.100,10.0.0.110,12h" >> ${D}${sysconfdir}/dnsmasq.conf

    echo "# Assign 10.0.0.100 to connected device for proper work of updater." >> ${D}${sysconfdir}/dnsmasq.conf
    echo "# Temporary hack. Need to be removed after proper fix." >> ${D}${sysconfdir}/dnsmasq.conf
    echo "# Uncomment following line and edit MAC of your device" >> ${D}${sysconfdir}/dnsmasq.conf
    echo "# dhcp-host=2e:09:0a:00:a0:41,10.0.0.100,infinite" >> ${D}${sysconfdir}/dnsmasq.conf
}
