#!/usr/bin/env bash


apt install zsh git -y
sudo -H -u pi sh -c '
    cd ~/;
    sh -c  "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended;
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions;
'

sed -i  -r -e  "s/^auth\s+required\s+pam_shells.so/auth         sufficient  pam_shells.so/g"  /etc/pam.d/chsh;
cat /etc/pam.d/chsh | grep pam_shells.so;
chsh -s ~/.oh-my-zsh;
sed -i  -r -e  "s/^auth\s+sufficient\s+pam_shells.so/auth           required    pam_shells.so/g"  /etc/pam.d/chsh;
cat /etc/pam.d/chsh | grep pam_shells.so;
