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


echo 'Done!'

