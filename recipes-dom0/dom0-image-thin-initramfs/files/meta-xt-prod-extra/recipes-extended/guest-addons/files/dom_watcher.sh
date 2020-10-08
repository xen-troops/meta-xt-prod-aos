#!/bin/sh

DOM_ID=`xl domid $1`

pipe=/tmp/$DOM_ID-reboot

if ! mkfifo $pipe ; then
    echo "Failed to create a pipe, is the script already running?"
    echo "Exiting."
    exit 1
fi

xenpath="/local/domain/$DOM_ID/control/user-reboot"
xenstore-write $xenpath 1
xenstore-chmod $xenpath b$DOM_ID

xenstore-watch $xenpath > $pipe &
XENSTORE_WATCH=$!
echo "xenstore-watch PID $XENSTORE_WATCH"
while read event ; do
    value="$(xenstore-read $xenpath)"
    [[ $value == 2* ]] && { echo "Rebooting"; reboot; }
done <$pipe
