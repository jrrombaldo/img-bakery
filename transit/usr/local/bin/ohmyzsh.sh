#!/usr/bin/env bash

/usr/local/bin/strict.sh


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




#    sudo -H -u pi sh -c 'cd ~/; sh -c  "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended'
#    sudo -H -u pi sh -c "cd ~/; git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions"
#    sudo -H -u pi sh -c "echo 'source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh'>> ~/.zshrc"
#    # disabling password prompt for chsh (hacky). The option "--unattended" does not set ZSH as the default shell
#    sed -i  -r -e  's/^auth\s+required\s+pam_shells.so/auth         sufficient  pam_shells.so/g'  /etc/pam.d/chsh
#    cat /etc/pam.d/chsh | grep pam_shells.so
#    chsh -s ~/.oh-my-zsh
#    # re-enabling password prompt for chsh
#    sed -i  -r -e  's/^auth\s+sufficient\s+pam_shells.so/auth           required    pam_shells.so/g'  /etc/pam.d/chsh
#    cat /etc/pam.d/chsh | grep pam_shells.so
