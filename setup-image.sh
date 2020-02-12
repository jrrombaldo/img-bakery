#!/bin/bash

echo "setting strict script"
set -xuo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; df -h; exit $s' ERR
IFS=$'\n\t'
set -x
echo "strict setup completed"


if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi



echo '
search ant.amazon.com amazon.com
nameserver 10.106.65.245
nameserver 10.106.65.205
nameserver 10.106.151.100
nameserver 10.106.49.51
' > /etc/resolv.conf                  

######### VARIABLES
    export HOST=${HOST:=rasp.local}
    export PI_PWD=${PI_PWD:=raspberry}


# non-root scripts fail without this, because /dev/* is mounted with different permissions
    chmod 666 /dev/null



######### INSTALLING PACKAGES
    echo "Checking disk space."; df -h
    apt clean && apt update --allow-releaseinfo-change
    apt install -y \
        net-tools \
        hdparm \
        iotop \
        iftop \
        htop \
        tcpdump \
        ethtool \
        speedtest-cli \
        iperf \
        git \
        zsh \
        vim




######### ISNTALLING DOCKER
    curl -sSL https://get.docker.com | sh
    sudo usermod -a -G docker pi
    apt install docker-compose -y



######### HEADLESS INSTALL 
    touch /boot/ssh
    echo "pi:$PI_PWD" | chpasswd
    echo "Setting hostname."
    echo "${HOST}" > /etc/hostname



######### CLEANING UP
    df -h
    apt -qq -y autoclean
    apt -qq -y autoremove
    apt -qq -y clean
