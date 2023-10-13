# Configure pacman

# Enable multilib
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
pacman -Sy

# Parallel Download
sed -i 's/#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf



echo 'Installing packages'

pacman -S --noconfirm --needed $(awk '!/^#|^$/ {print $1}' PKGS.txt)


echo "Configuring system"

# Current user
USER=$(grep home /etc/passwd|cut -d: -f1)

# Script directory
DIR=$PWD


# Create .xinitrc file for startx
cd /home/$USER
touch .xinitrc
echo "export DESKTOP_SESSION=plasma" >> .xinitrc
echo "exec startplasma-x11" >> .xinitrc


# Set max cores according system on makepkg.conf
sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j$(nproc)"/' /etc/makepkg.conf





# Make swapfile and enable it
if free | awk '/^Swap:/ {exit !$2}'; then
    echo "Found swap!"
else
    RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    RAM_MB=$(expr $RAM_KB / 1024 )

    dd if=/dev/zero of=/swapfile bs=1M count=$RAM_MB status=progress
    chmod 0600 /swapfile
    mkswap -U clear /swapfile
    swapon /swapfile

    echo "# /swapfile" >> /etc/fstab
    echo "/swapfile none    swap    defaults,nofail    0   0" >> /etc/fstab
fi


# Setup zsh shell
echo "Setting up zsh"

# Install zsh-powerline10k from AUR
git clone https://aur.archlinux.org/zsh-theme-powerlevel10k-git.git
chown -R $USER zsh-theme-powerlevel10k-git
cd zsh-theme-powerlevel10k-git

sudo -u $USER zsh -c 'makepkg -s'
pacman -U "$(find . -type f -name "*tar.zst")" --noconfirm --needed

# Copy config files to /home and set default shell
cd $DIR
cp -rv zsh_config/. /home/$USER
chsh -s /bin/zsh $USER


echo 'Done!'
