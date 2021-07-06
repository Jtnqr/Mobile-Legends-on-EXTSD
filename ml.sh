#!/bin/sh

> /data/media/0/ml_log.txt
exec >> /data/media/0/ml_log.txt
exec 2>&1

SCRIPT_PATH="`dirname \"$0\"`"

## CAUTION! ##
# THIS VARIABLE ASSIGNMENT WILL NOT WORK IF
# THERE'S MORE THAN 1 EXTERNAL STORAGE CONNECTED!
EXT_SDCARD=
if [[ $EXT_SDCARD == "" ]]; then
    echo "Variable is empty"
    EXT_TEMP="$(ls -d /mnt/media_rw/* | head -n 1)" || exit 2
    EXT_SDCARD="$EXT_TEMP"
    sed -i -r "s#^(EXT_SDCARD=).*#\1$EXT_TEMP#" $SCRIPT_PATH/ml.sh
    exit
fi

APP_NAME="com.mobile.legends"
SD0_DIR="/data/media/0/Android/data/$APP_NAME"
SD1_DIR="$EXT_SDCARD/Android/data/$APP_NAME"

if [ ! -f /system/bin/bindfs ]; then
    if [ ! -f /data/media/0/bindfs ]; then
        echo "bindfs is not found!"
        exit
    fi
    cp /data/media/0/bindfs /bin/bindfs
    chmod 0775 /bin/bindfs
    chown 0:2000 /bin/bindfs
    echo "Successfully copied bindfs"
fi

while ! mountpoint -q "$EXT_SDCARD"; do
    sleep 1
    echo X
done && echo "$EXT_SDCARD is mounted"

bindfs -u $(stat -c %u /sdcard/Android/data/$APP_NAME) -g 9997 -p a-rwx,ug+rw,ug+X $SD1_DIR /mnt/runtime/write/emulated/0/Android/data/$APP_NAME && \
echo "$APP_NAME is mounted successfully" || \
echo "Failed to mount $APP_NAME"
