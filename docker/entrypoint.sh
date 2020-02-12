#!/usr/bin/env bash

# fail if any lines returns a non-zero status
 set -xuo pipefail
 trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR
 IFS=$'\n\t'




 ######### SAFETY CHECKS

    if [[ ! -f "/setup-image.sh" ]]; then
        echo "you haven't mounted the /setup-image.sh script"
        exit 1
    fi

    if [[ ! -d "/result" ]]; then
        echo "you haven't mounted the /result directory"
        exit 2
    fi

     # Ensure we are root
     if [[ $EUID -ne 0 ]]; then
         echo "This script must be run as root" 1>&2
         exit 3
     fi


 ######### CLEAN UP BITS

     # Unmount drives and general cleanup on exit, the trap ensures this will always
     # run execpt in the most extream cases.
     cleanup() {

         if [[ -d "${MOUNT}" ]]; then
             umount "${MOUNT}/dev/pts" || true
             umount "${MOUNT}/dev" || true
             umount "${MOUNT}/proc" || true
             umount "${MOUNT}/sys" || true
             umount "${MOUNT}/boot" || true
             umount "${MOUNT}" || true
             sleep 2 #ensure doesn't still mounted
             rm -rf  "${MOUNT}" || true
         fi
         [[ -n "${LOOPDEV:-}" ]] && losetup --detach "${LOOPDEV}" || true
         rm -rf ./result/${IMG_NAME} || true
         rm -rf ./result/${IMG_NAME}.bck || true
     }
     trap cleanup EXIT



 ######### Download and preparing image file
 
    ORIGINAL="${IMG_NAME}-original.zip"

    [[ ! -f "/result/${ORIGINAL}" ]] && wget -O "/result/${ORIGINAL}" "${IMG_URL}"
    (ls /result/*.img >> /dev/null 2>&1 && rm /result/*.img) || echo "no .img files to remove"
    unzip -u "/result/${ORIGINAL}" -d /result/
    # TODO caputre image name (and perhaps the version)
    mv "$(ls /result/*.img | head -n 1)" "/result/${IMG_NAME}"


 ######### PREPARING PARTITION

    qemu-img info  /result/${IMG_NAME}
    qemu-img resize  /result/${IMG_NAME} +${INCREASE_BY}
    qemu-img info  /result/${IMG_NAME}

    LOOPDEV=$(losetup --find -P --show "/result/${IMG_NAME}")
    echo "Created loopback device ${LOOPDEV}"

    partprobe --summary ${LOOPDEV}
    parted --script "${LOOPDEV}" print

    parted --script "${LOOPDEV}" resizepart 2 100%
    parted --script "${LOOPDEV}" print
    e2fsck -yf "${LOOPDEV}p2"
    resize2fs "${LOOPDEV}p2"
    echo "Finished resizing disk image."

    ls "${LOOPDEV}"*
    BOOTDEV=$(ls "${LOOPDEV}"p1)
    ROOTDEV=$(ls "${LOOPDEV}"p2)
    partprobe  --summary "${LOOPDEV}"



 ######### MOUNTING PARTITIONS

     [[ ! -d "${MOUNT}" ]] && mkdir -p "${MOUNT}"; mount "${ROOTDEV}" "${MOUNT}"
     [[ ! -d "${MOUNT}/boot" ]] && mkdir "${MOUNT}/boot"; mount "${BOOTDEV}" "${MOUNT}/boot"
     mount --bind /proc "${MOUNT}/proc"
     mount --bind /sys "${MOUNT}/sys"
     mount --bind /dev "${MOUNT}/dev"
     mount --bind /dev/pts "${MOUNT}/dev/pts"


 ######### PREPARING AND RUNNING CHROOT
    for file in $(find /transit -type f | sed -e 's/\/transit//g'); do
        echo "copying file \"$file\""
        install -Dm755 "/transit/$file" "${MOUNT}/$file";
    done

     # qemu required to be built on travis-ci, without it does not recognise the setup.sh script.
     cp /usr/bin/qemu-arm-static "${MOUNT}/usr/bin/"

     cp "${MOUNT}/etc/ld.so.preload" "${MOUNT}/etc/_ld.so.preload"
     echo "" > "${MOUNT}/etc/ld.so.preload"
     install -Dm755 "/setup-image.sh"  "${MOUNT}/setup-image.sh"
     chroot "${MOUNT}" /setup-image.sh
     mv "${MOUNT}/etc/_ld.so.preload" "${MOUNT}/etc/ld.so.preload"


 ######### SHRINK IMAG

     mv /result/${IMG_NAME} /result/${IMG_NAME}.bck
     pishrink.sh -rz /result/${IMG_NAME}.bck "/result/${IMG_NAME}"





