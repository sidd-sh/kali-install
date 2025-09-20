#!/bin/bash

# Quick and dirty script for nice minimal setup

# First upgrade and update to get started
sudo apt update && sudo apt upgrade -y

# Basic tools etc
sudo apt install -y pyenv yq jq open-vm-tools wget curl git tmux thunar pipx xsel stow zsh libfontconfig1-dev apt-transport-https

# Install fonts
mkdir -p ~/.local/share/fonts/
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/Meslo.zip
unzip Meslo.zip -d ~/.local/share/fonts
rm Meslo.zip
fc-cache -fv

# Build nvim from source because of the outdated packages
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
chmod u+x nvim-linux-x86_64.appimage
sudo mv nvim-linux-x86_64.appimage /usr/bin/nvim

# Install my dotfiles and configs
cd ~
git clone https://github.com/sidd-sh/dotfiles
# Copy a bunch of configurations
cd ~/dotfiles
stow tmux
stow nvim

# Install Oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autocomplete
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
rm ~/.zshrc
stow zshrc

# Because the fzf version is broken in the repos
wget https://github.com/junegunn/fzf/releases/download/v0.65.2/fzf-0.65.2-linux_amd64.tar.gz -O fzf.tar.gz
tar xvzf fzf.tar.gz
rm fzf.tar.gz
sudo mv fzf /usr/bin/fzf

# Some nice to have tools
curl --proto '=https' --tlsv1.2 -sSLf "https://git.io/JBhDb" | sh # Termscp is a nice TUI for ftp/SFTP/SMB etc

# Rip grep is just better grep, better cat, better ls
sudo apt install ripgrep bat eza 

# Powerlevel 10k for faster terminal
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

# Zoxide for better cd
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# Flatpak is useful so adding the repository
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Faster find
wget https://github.com/sharkdp/fd/releases/download/v10.2.0/fd-musl_10.2.0_amd64.deb
sudo dpkg -i fd-musl_10.2.0_amd64.deb
rm fd-musl_10.2.0_amd64.deb

# Nice terminal screenshots
wget https://github.com/homeport/termshot/releases/download/v0.6.0/termshot_0.6.0_linux_amd64.tar.gz -O termshot.tar.gz
tar xvzf termshot.tar.gz
rm termshot.tar.gz LICENSE README.md
sudo mv termshot /usr/bin/termshot

chsh -s /usr/bin/zsh

# Download TPM just in to download plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

pipx install netexec

curl -fsSL https://pyenv.run | bash

echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init - zsh)"' >> ~/.zshrc
