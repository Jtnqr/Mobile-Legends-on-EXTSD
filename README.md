# Mobile Legends on EXTERNAL_SDCARD

## Introduction

This script allow you to mount your Mobile Legends folder on EXTERNAL_SDCARD without reformatting it.
Using bindfs as a program to mount folders.

## Current Issues

1. Must run the script before putting in service.d directory to get full path of EXTERNAL_SDCARD.
2. In order to get full path of EXTERNAL_SDCARD, the device must have 1 External Storage attached or it will crash.
3. Must move the content of com.mobile.legends directory manually using file explorer.

## Usage
1. Download [bindfs (ARM64)](https://www.androidfilehost.com/?fid=4349826312261681311) and put it on /sdcard.
2. Run the script first using terminal emulator `bash ml.sh` before putting the script to directory.
3. Put the script into magisk service.d directory `/data/adb/service.d`.
4. Restart to get it mounted.
5. Open ml_log.txt on /sdcard to see errors.

## Credits
- Kudos for compiled ARM64 bindfs from [Irfan Latif](https://android.stackexchange.com/questions/217741/how-to-bind-mount-a-folder-inside-sdcard-with-correct-permissions) post in Android Enthusiasts.
