
do_install_append() {
    sed -i -e 's/.*Storage=.*/Storage=persistent/' ${D}${sysconfdir}/systemd/journald.conf
}
