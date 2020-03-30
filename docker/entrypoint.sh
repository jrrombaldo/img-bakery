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

     # export ORIGINAL="original-${IMG_NAME}"
     export ORIGINAL=$(basename "${IMG_URL}")
     export IMG_NAME="baked-${ORIGINAL}"


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
         # rm -rf ./result/${IMG_NAME} || true
         rm -rf /result/${IMG_NAME}.bck || true
        # ls -1 /result | egrep -v "^(${ORIGINAL}|${IMG_NAME}.img.zip)$" | xargs -I {} rm -r /result/{} || true
        # ls -1 /result/${IMG_NAME}.* | egrep -v "^/result/(${ORIGINAL}|${IMG_NAME}.img.zip)$" | xargs -I {} rm -r {} || true
     }
     trap cleanup EXIT



 ######### Download and preparing image file


    [[ ! -f "/result/${ORIGINAL}" ]] && \
      wget -nv --show-progress --progress=bar:force:noscroll \
      -O "/result/${ORIGINAL}" "${IMG_URL}"

    if [ $(file "/result/${ORIGINAL}" | grep -c "Zip archive data") -eq 1 ]
    then
        echo "compressed with ZIP";
        unzip -u "/result/${ORIGINAL}" -d /result/

    elif [ $(file "/result/${ORIGINAL}" | grep -c "XZ compressed data") -eq 1 ]
    then
        echo "compressed with XZ";
        xz -dc < "/result/${ORIGINAL}" > "/result/${IMG_NAME}"

    elif [ $(file "/result/${ORIGINAL}" | grep -c "gzip compressed data") -eq 1 ]
    then
        echo "compressed with GZ";
        gunzip --decompress --keep --stdout "/result/${ORIGINAL}" > "/result/${IMG_NAME}"

        # check if it was tar.gz
        if [ $(file "/result/${IMG_NAME}" | grep -c "POSIX tar archive") -eq 1 ]
        then
            tar -vxf /result/${IMG_NAME}
            # TODO need to investigate how to check the output
        fi
    elif [ $(file "/result/${ORIGINAL}" | grep -c "POSIX tar archive") -eq 1 ]
    then
        tar -vxf /result/${IMG_NAME}
        # TODO need to investigate how to check the output
    fi

    # TODO caputre image name (and perhaps the version)
    mv "$(ls /result/*.img | head -n 1)" "/result/${IMG_NAME}" || true # they might be the same


    if [ $(file "/result/${IMG_NAME}" | grep -c "DOS/MBR boot sector") -eq 1 ]
    then
        echo "/result/${IMG_NAME} is .IMG, happy days ... "
    else
        echo "/result/${IMG_NAME} is not an IMG, need to adjust the script  "
        file "/result/${IMG_NAME}"
        exit 1
    fi



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


     find ${MOUNT}/etc/ -name ld.so.preload | xargs -I {} mv {} {}.backup
     echo "" > "${MOUNT}/etc/ld.so.preload"

     install -Dm755 "/setup-image.sh"  "${MOUNT}/setup-image.sh"
     chroot "${MOUNT}" /setup-image.sh

     find ${MOUNT}/etc/ -name ld.so.preload.backup | xargs -I {} mv {} ${MOUNT}/etc/ld.so.preload


 ######### SHRINK IMAG

     mv /result/${IMG_NAME} /result/${IMG_NAME}.bck
    #  pishrink.sh -rz /result/${IMG_NAME}.bck "/result/${IMG_NAME}"
     pishrink.sh -r /result/${IMG_NAME}.bck /result/${IMG_NAME}.img
     cd /result && zip ${IMG_NAME}.img.zip ${IMG_NAME}.img


    echo  "\n\nRESULT = $?\n\n"



