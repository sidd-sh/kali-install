#!/bin/bash

sudo apt update && sudo apt upgrade -y

sudo apt-get install -y wget curl git thunar fzf maim
sudo apt-get install -y arandr flameshot arc-theme feh i3blocks i3status i3 i3-wm lxappearance pipx rofi unclutter cargo compton papirus-icon-theme imagemagick
sudo apt-get install -y libxcb-shape0-dev libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev xcb libxcb1-dev libxcb-icccm4-dev libyajl-dev libev-dev libxcb-xkb-dev libxcb-cursor-dev libxkbcommon-dev libxcb-xinerama0-dev libxkbcommon-x11-dev libstartup-notification0-dev libxcb-randr0-dev libxcb-xrm0 libxcb-xrm-dev autoconf meson
sudo apt-get install -y libxcb-render-util0-dev libxcb-shape0-dev libxcb-xfixes0-dev 

# Required for picom
sudo apt install libconfig-dev libdbus-1-dev libegl-dev libev-dev libgl-dev libepoxy-dev libpcre2-dev libpixman-1-dev libx11-xcb-dev libxcb1-dev libxcb-composite0-dev libxcb-damage0-dev libxcb-glx0-dev libxcb-image0-dev libxcb-present-dev libxcb-randr0-dev libxcb-render0-dev libxcb-render-util0-dev libxcb-shape0-dev libxcb-util-dev libxcb-xfixes0-dev meson ninja-build uthash-dev

cd ~

mkdir -p ~/.local/share/fonts/

wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Iosevka.zip
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/RobotoMono.zip
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/Meslo.zip

unzip Iosevka.zip -d ~/.local/share/fonts/
unzip RobotoMono.zip -d ~/.local/share/fonts/
unzip Meslo.zip -d ~/.local/share/fonts

fc-cache -fv
# Install the terminal recognized by i3
sudo apt install alacritty
# Install i3
sudo apt install i3
# Install stow for easy management of dotfiles
sudo apt install stow
# Pretty prompt
curl -sS https://starship.rs/install.sh | sh
sudo apt install polybar

git clone https://github.com/sidd-sh/dotfiles
cd dotfiles
# Copy a bunch of configurations
stow tmux
stow alacritty
stow i3
stow picom
stow nvim
stow polybar
stow rofi
stow backgrounds
stow starship

# Now to install some tools I needed for my Offsec courses
# VSCode
wget "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" -O vscode.deb 
sudo dpkg -i ./vscode.deb
rm vscode.deb
# JD-GUI
sudo apt install jd-gui

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
stow zshrc

# If you have i3 and alacritty setup - you need to do this ;)
sudo apt install fastfetch
echo "After reboot: Select i3 on login"
sleep 5
clear
fastfetch
