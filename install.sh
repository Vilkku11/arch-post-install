echo 'Installing packages'

PKGS=(
    #Desktop environment
    'xorg'
    'xorg-xinit'
    'plasma'
    #Audio
    'pipewire'
    'easyeffects'
    #Other
    'base-devel'
    'kitty'
    'firefox'
    'dolphin'
    'git'
    'htop'
    'systemd-resolvconf'

)

for PKG in "${PKGS[@]}"; do
    echo "Installing: ${PKG}"
    pacman -S "$PKG" --noconfirm --needed
done
echo "Configuring system"

# Create .xinitrc file for startx
USER=$(grep home /etc/passwd|cut -d: -f1)
cd /home/$USER
touch .xinitrc
echo "export DESKTOP_SESSION=plasma" > .xinitrc
echo "exec startplasma-x11" >> .xinitrc


# Enable multithreading on makepkg.conf
sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j$(nproc)"/' /etc/makepkg.conf


# Enable multilib
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf


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


echo 'Done!'

