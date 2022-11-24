echo 'Installing packages'

PKGS=(
    #Desktop environment
    'xorg'
    'xorg-xinit'
    'plasma'
    #Audio
    'pipewire'
    #Other
    'base-devel'
    'kitty'
    'firefox'
    'dolphin'

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
echo 'Done!'

