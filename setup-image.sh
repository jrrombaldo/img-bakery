#!/bin/bash

########## Setup script error handling see https://disconnected.systems/blog/another-bash-strict-mode for details
    set -xuo pipefail
    trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; df -h; exit $s' ERR
    IFS=$'\n\t'
    set -x

    # make sure it runs as root
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root" 1>&2
        exit 1
    fi
    echo "Checking disk space."
    df -h

######### VARIABLES
    export HOST=${HOST:=share.local}
    export PI_PWD=${PI_PWD:=raspberry}


######### setting hostname
    echo "Setting hostname."
    echo ${HOST} > /etc/hostname
    cat /etc/hostname


######### headless starting with high-resolution and SSH access
    touch /boot/ssh
    echo '' >> /boot/config.txt
    echo '' >> /boot/config.txt
    echo 'hdmi_force_hotplug=1' >> /boot/config.txt
    echo 'hdmi_group=2' >> /boot/config.txt
    echo 'hdmi_mode=69' >> /boot/config.txt

    echo "pi:$PI_PWD" | chpasswd


######### CALLING SCRIPTS

    # chmod 666 /dev/null # non-root scripts fail without this, because /dev/* is mounted with different permissions

    apt clean && apt update --allow-releaseinfo-change

    /usr/local/bin/docker.sh
    /usr/local/bin/ohmyzsh.sh
    /usr/local/bin/buonjour.sh


######### cleaning the image
    df -h
    apt -qq -y autoclean
    apt -qq -y autoremove
    apt -qq -y clean
