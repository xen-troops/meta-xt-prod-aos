# !/bin/sh

systemctl restart aos.target

# reboot domf
xenstore-write control/user-reboot 2  