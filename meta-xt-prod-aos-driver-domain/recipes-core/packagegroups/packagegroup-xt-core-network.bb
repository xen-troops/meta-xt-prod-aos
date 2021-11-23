SUMMARY = "DomD networking components"

LICENSE = "MIT"

inherit packagegroup

RDEPENDS_packagegroup-xt-core-network = "\
    xen-network \
    dnsmasq \
    nftables \
    ntpdate-systemd \
    tzdata \
"
