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




######### VARIABLES
    export HOST=${HOST:=rasp.local}
    # export PI_PWD=${PI_PWD:=raspberry}


# non-root scripts fail without this, because /dev/* is mounted with different permissions
    chmod 666 /dev/null


######### HEADLESS INSTALL
    touch /boot/ssh
    # echo "pi:$PI_PWD" | chpasswd
    echo "Setting hostname."
    echo "${HOST}" > /etc/hostname



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
        wget \
        zsh \
        vim


######### ISNTALLING DOCKER
    curl -sSL https://get.docker.com | sh
    sudo usermod -a -G docker pi
    apt install docker-compose -y


######### ISNTALLING OHMYZSH + AUTOCOMPLETE

    echo "disabling the chsh password requirement"
    cat /etc/pam.d/chsh | grep pam_shells.so;
    sed -i  -r -e  "s/^auth\s+required\s+pam_shells.so/auth         sufficient  pam_shells.so/g"  /etc/pam.d/chsh;
    cat /etc/pam.d/chsh | grep pam_shells.so;

    su pi -c '
    sh  -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    chsh -s $(which zsh)

    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    cat ~/.zshrc| grep -i "^plugins"
    sed -i  -r -e "s/^plugins\=.*$/plugins=(git zsh-autosuggestions)/g" ~/.zshrc
    cat ~/.zshrc| grep -i "^plugins"
    '

    echo "enabling back the chsh password requirement"
    sed -i  -r -e  "s/^auth\s+sufficient\s+pam_shells.so/auth           required    pam_shells.so/g"  /etc/pam.d/chsh;
    cat /etc/pam.d/chsh | grep pam_shells.so;




######### CLEANING UP
    df -h
    apt -qq -y autoclean
    apt -qq -y autoremove
    apt -qq -y clean
    rm -rf /var/lib/apt/lists/* \
    rm -rf /tmp/* \
    rm -rf /var/tmp

