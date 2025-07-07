#!/bin/bash

# First upgrade and update to get started
sudo apt update && sudo apt upgrade -y

# Some basic tools: better df - duf, better wget - aria2, better du - ncdu, tre is better tree
sudo apt-get install -y tre-command duf yq jq aria2 ncdu open-vm-tools open-vm-tools-desktop wget curl git tmux thunar flameshot pipx cargo papirus-icon-theme imagemagick xsel flatpak alacritty stow jd-gui rustc zsh

# Install fonts
mkdir -p ~/.local/share/fonts/
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Iosevka.zip
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/RobotoMono.zip
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/Meslo.zip
unzip Iosevka.zip -d ~/.local/share/fonts/
unzip RobotoMono.zip -d ~/.local/share/fonts/
unzip Meslo.zip -d ~/.local/share/fonts
rm Iosevka.zip RobotoMono.zip Meslo.zip
fc-cache -fv

# Build nvim from source because of the outdated packages
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
chmod u+x nvim-linux-x86_64.appimage
sudo mv nvim-linux-x86_64.appimage /usr/bin/nvim

# Install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
. "$HOME/.cargo/env"
# If nvim is not working then try this:
# ./nvim-linux-x86_64.appimage --appimage-extract
# ./squashfs-root/AppRun --version
# Optional: exposing nvim globally.
#sudo mv squashfs-root /
#sudo ln -s /squashfs-root/AppRun /usr/bin/nvim

# Install my dotfiles and configs
cd ~
git clone https://github.com/sidd-sh/dotfiles
# Copy a bunch of configurations
cd ~/dotfiles
stow tmux
stow alacritty
stow nvim
stow backgrounds
# Install Oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autocomplete
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
stow zshrc

# Because the fzf version is broken in the repos
wget https://github.com/junegunn/fzf/releases/download/v0.64.0/fzf-0.64.0-linux_amd64.tar.gz -O fzf.tar.gz
tar xvzf fzf.tar.gz
rm fzf.tar.gz
sudo mv fzf /usr/bin/fzf

# VSCode
wget "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" -O vscode.deb 
sudo dpkg -i ./vscode.deb
rm vscode.deb

# Some nice to have tools
curl --proto '=https' --tlsv1.2 -sSLf "https://git.io/JBhDb" | sh # Termscp is a nice TUI for ftp/SFTP/SMB etc

# Rip grep is just better grep, better cat, better ls
sudo apt install ripgrep bat exa 
# Better sed
cargo install sd

# Powerlevel 10k for faster terminal
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

# Zoxide for better cd
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# Flatpak is useful so adding the repository
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Pet is for saving command snippets to make life easier from the cmdline
wget https://github.com/knqyf263/pet/releases/download/v1.0.1/pet_1.0.1_linux_amd64.deb
sudo dpkg -i pet_1.0.1_linux_amd64.deb
rm pet_1.0*

# Install powershell and the dotnet to build stuff
source /etc/os-release
wget -q https://packages.microsoft.com/config/debian/$VERSION_ID/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
sudo apt update && sudo apt install -y powershell dotnet-sdk-9.0 aspnetcore-runtime-9.0

# Commandline web search
go install github.com/zquestz/s@latest

# Faster find
wget https://github.com/sharkdp/fd/releases/download/v10.2.0/fd-musl_10.2.0_amd64.deb
sudo dpkg -i fd-musl_10.2.0_amd64.deb
rm fd-musl_10.2.0_amd64.deb

# Nice terminal screenshots
wget https://github.com/homeport/termshot/releases/download/v0.6.0/termshot_0.6.0_linux_amd64.tar.gz -O termshot.tar.gz
tar xvzf termshot.tar.gz
rm termshot.tar.gz LICENSE README.md
sudo mv termshot /usr/bin/termshot

# Nice command line email client for testing
curl -sSL https://raw.githubusercontent.com/pimalaya/himalaya/master/install.sh | PREFIX=~/.local sh

# Navigable cheat sheet
bash <(curl -sL https://raw.githubusercontent.com/denisidoro/navi/master/scripts/install)

chsh -s /usr/bin/zsh

# Download TPM just in to download plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
