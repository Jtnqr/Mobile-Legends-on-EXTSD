#!/bin/sh

### User Variables ###

APP_NAME="com.mobile.legends"

## WARNING! ##
# IF YOU CHANGED THE SCRIPT NAME, EDIT THIS LINE
# TO MAKE THE PROGRAM WORK CORRECTLY!
SCRIPT_NAME="ml"

### Program Variables ###

## WARNING!! ##
# THIS EXT_SDCARD ASSIGNMENT WILL NOT WORK IF
# THERE'S MORE THAN 1 EXTERNAL STORAGE CONNECTED!
EXT_SDCARD=

SCRIPT_PATH="`dirname \"$0\"`" # Script path
SD0_DIR="/data/media/0/Android/data/$APP_NAME"
SD1_DIR="$EXT_SDCARD/Android/data/$APP_NAME"
PRINT_LOGS=1
MOUNT_ML=1

### Program Options ###

if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    echo "Mobile Legends mount on EXT_SDCARD"
    echo
    echo "Available arguments:"
    echo "-h --help      Display this"
    echo "-d --display   Print stdout and stderr to terminal"
    echo "-n --nomount   Disable mount(for testing)"
    echo
    echo "https://github.com/jTnqr/Mobile-Legends-on-EXTSD"
    echo "Created by jTnqr"
    exit
else
    if [[ "$1" == "-d" ]] || [[ "$1" == "--display" ]]; then
        PRINT_LOGS=0
    fi
    if [[ "$1" == "-n" ]] || [[ "$1" == "--nomount" ]]; then
        MOUNT_ML=0
    fi
fi

if [[ $PRINT_LOGS == 1 ]];then
    > /data/media/0/ml_log.txt
    exec >> /data/media/0/ml_log.txt
    exec 2>&1
fi

### Functions ###

function findEXTSD() {
    if [[ $EXT_SDCARD == "" ]]; then
        echo "ERROR: \$EXT_SDCARD is empty. Searching..."
        EXT_TEMP="$(ls -d /mnt/media_rw/* | head -n 1)" || \
        echo "ERROR: EXT_SDCARD is not found." && \
        exit 2
        EXT_SDCARD="$EXT_TEMP"
        sed -i -r "s#^(EXT_SDCARD=).*#\1$EXT_TEMP#" $SCRIPT_PATH/$SCRIPT_NAME.sh
        exit
    fi
}

function checkMount() {
    if [[ "$1" == "$EXT_SDCARD" ]]; then
        while ! mountpoint -q "$EXT_SDCARD"; do
            sleep 1
        done && echo "INFO: EXT_SDCARD is mounted."
    elif [[ "$(awk '/fuse/ && /$1/ {print 1}' /proc/mounts)" == 1 ]]; then
        return 1
    fi
    return 0
}

function checkProgram() {
    if [ ! -f /system/bin/bindfs ]; then
        if [ ! -f /data/media/0/bindfs ]; then
            echo "ERROR: bindfs is not found on /sdcard!"
            exit
        fi
        
        if [ ! -w / ]; then
            RO_ROOT=1
            mount -o rw,remount / || \
            echo "ERROR: Cannot change / to r/w!" && \
            exit
        fi
        
        cp /data/media/0/bindfs /bin/bindfs
        chmod 0775 /bin/bindfs
        chown 0:2000 /bin/bindfs
        
        if [[ RO_ROOT == 1 ]]; then
            mount -o ro,remount /
        fi

        if [ -f /system/bin/bindfs ]; then
            echo "SUCCESS: Successfully copied bindfs!"
        else
            echo "ERROR: Cannot copy bindfs!"
            exit
        fi
    fi
}

function moveFiles() {
    ( cd $SD0_DIR && tar cf - . ) | ( cd $SD1_DIR && tar xvf - . ) && \
    rm -rf $SD0_DIR/files $SD0_DIR/cache
}

function mountML() {
    if [[ "$(checkMount $SD0_DIR)" == 1 ]]; then
        echo "ERROR: $APP_NAME is already mounted!"
        exit
    else
        if [ "$(ls -A $SD0_DIR)" ]; then
            echo "INFO: Moving files..."
            moveFiles
        fi
        bindfs -u $(stat -c %u /sdcard/Android/data/$APP_NAME) -g 9997 -p a-rwx,ug+rw,ug+X $SD1_DIR /mnt/runtime/write/emulated/0/Android/data/$APP_NAME && \
        echo "SUCCESS: $APP_NAME is mounted successfully!" || \
        echo "ERROR: Failed to mount $APP_NAME!"
    fi
}

### Main ###

findEXTSD
checkProgram
checkMount $EXT_SDCARD

if [[ $MOUNT_ML == 1 ]]; then
    mountML
fi
