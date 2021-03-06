#!/bin/sh
#
# Panda boards re-imaging script
#
# This script is retrieved and executed from a initramfs or live build running the panda board
#
#
#

log () {
   logger -p local0.info -t "second-stage.sh" "${1}"
   echo ${1} >> /opt/log.txt
}

log "Beginning second-stage.sh"
mkdir -p /opt/artifacts /opt/scripts /opt/mnt/boot /opt/mnt/system /opt/mnt/userdata

OUTPUT=$(ntpdate ntp.build.mozilla.com)
log "${OUTPUT}"

WGET_OUTPUT=$(wget -nv --directory-prefix=/opt/artifacts/ http://192.168.224.6/panda-test/panda-jb-gcc47-tilt-stable-blob-12.08-release/system.tar.bz2 2>&1)
log "${WGET_OUTPUT}"
WGET_OUTPUT=$(wget -nv --directory-prefix=/opt/artifacts/ http://192.168.224.6/panda-test/panda-jb-gcc47-tilt-stable-blob-12.08-release/userdata.tar.bz2 2>&1)
log "${WGET_OUTPUT}"
WGET_OUTPUT=$(wget -nv --directory-prefix=/opt/artifacts/ http://192.168.224.6/panda-test/panda-jb-gcc47-tilt-stable-blob-12.08-release/boot.tar.bz2  2>&1)
log "${WGET_OUTPUT}"

log "Formatting partitions"
mkfs.ext4 -L "System" /dev/mmcblk0p2
mkfs.ext4 -L "Cache" /dev/mmcblk0p3
mkfs.ext4 -L "Userdata" /dev/mmcblk0p5
mkfs.ext4 -L "Media" /dev/mmcblk0p6

log "Mounting partitions"
mount -t vfat /dev/mmcblk0p1 /opt/mnt/boot
mount -t ext4 /dev/mmcblk0p2 /opt/mnt/system
mount -t ext4 /dev/mmcblk0p5 /opt/mnt/userdata

log "Extracting artifacts"
tar -jxf /opt/artifacts/boot.tar.bz2 -C /opt/mnt/boot --strip=1 boot/uImage boot/uInitrd
tar -jxf /opt/artifacts/system.tar.bz2 -C /opt/mnt/system --strip=1 system
tar -jxf /opt/artifacts/userdata.tar.bz2 -C /opt/mnt/userdata --strip=1 data

log "Unmounting partitions"
umount /opt/mnt/boot /opt/mnt/system /opt/mnt/userdata

log "Imaging complete. Rebooting"
reboot

exit 0

