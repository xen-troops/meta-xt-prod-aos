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

    # We use special configuration for CB:
    # - only one device is connected to eth0.2
    # - this connected device must have IP 10.0.0.100
    # - connected device can be replaced (we can't hardcode MAC)
    # For now best solution is to assign 10.0.0.100 to anything
    # that is connected to eth0.2.
    # To do this we
    # 1) assign pool of 1 IP
    # 2) prevent dnsmasq from storing leases across reboot using /var/run as storage
    #    this results in reassignment of addresses on each reboot of CB.
    echo "dhcp-range=eth0.2,10.0.0.100,10.0.0.100,12h" >> ${D}${sysconfdir}/dnsmasq.conf
    echo "dhcp-leasefile=/var/run/dnsmasq.leases" >> ${D}${sysconfdir}/dnsmasq.conf
}
