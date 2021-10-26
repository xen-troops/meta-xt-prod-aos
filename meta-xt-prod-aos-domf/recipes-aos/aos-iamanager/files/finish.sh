# !/bin/sh

# This is WA. TBD: how to deploy certificates for domd UM
ssh -o "ServerAliveInterval=1" -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null" root@192.168.0.1 'mkdir -p /var/aos/crypt/um; sync'
scp -r -o "ServerAliveInterval=1" -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null" /var/aos/crypt/um/*  root@192.168.0.1:/var/aos/crypt/um
ssh -o "ServerAliveInterval=1" -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null" root@192.168.0.1 'sync'

sync

# system reboot
( sleep 2 ; xenstore-write control/user-reboot 2 ) &
