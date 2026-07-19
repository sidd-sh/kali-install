#!/usr/bin/env bash
set -euo pipefail

# =============================================================
# Interactivity helpers
# =============================================================
ASSUME_YES=0
while getopts ":y" opt; do
  case "$opt" in
    y) ASSUME_YES=1 ;;
    *) echo "Usage: $0 [-y]   (-y accepts every default, non-interactive)"; exit 1 ;;
  esac
done

# confirm "question" default_y_or_n -> 0 (yes) or 1 (no)
confirm() {
  local prompt="$1" default="${2:-y}" yn
  if [[ "$ASSUME_YES" == "1" ]]; then
    [[ "$default" == "y" ]] && return 0 || return 1
  fi
  if [[ "$default" == "y" ]]; then
    read -rp "$prompt [Y/n] " yn; yn=${yn:-y}
  else
    read -rp "$prompt [y/N] " yn; yn=${yn:-n}
  fi
  [[ "$yn" =~ ^[Yy]$ ]]
}

IS_WSL=0
if grep -qi microsoft /proc/version 2>/dev/null; then
  IS_WSL=1
  echo "WSL detected — GUI-only components (VS Code, Alacritty, fonts, desktop extras) will default to 'skip'."
fi
gui_default() { [[ "$IS_WSL" == "1" ]] && echo n || echo y; }

VIRT=$(systemd-detect-virt 2>/dev/null || echo none)

# =============================================================
# 1. System update
# =============================================================
sudo apt update && sudo apt upgrade -y

# =============================================================
# 2. Base CLI packages (always installed — the actual daily-driver toolset)
# =============================================================
sudo apt install -y \
  tre-command duf yq jq aria2 ncdu \
  wget curl git tmux imagemagick xsel flatpak stow \
  jd-gui zsh libfontconfig1-dev apt-transport-https \
  ripgrep bat eza fd-find golang-go

# Ubuntu ships bat/fd under renamed binaries — symlink to the common names
sudo ln -sf "$(command -v batcat)" /usr/local/bin/bat
sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd

NEED_EZA_FALLBACK=0
command -v eza &>/dev/null || NEED_EZA_FALLBACK=1

# =============================================================
# 3. Docker (optional — skip if you're relying on Docker Desktop's WSL integration)
# =============================================================
if confirm "Install Docker (docker.io) + add $USER to the docker group?" y; then
  sudo apt install -y docker.io
  sudo usermod -aG docker "$USER"
fi

# =============================================================
# 4. VMware guest tools (only offered if a VMware VM is actually detected)
# =============================================================
if [[ "$VIRT" == "vmware" ]]; then
  if confirm "VMware VM detected — install open-vm-tools (+ desktop integration)?" y; then
    sudo apt install -y open-vm-tools open-vm-tools-desktop
  fi
fi

# =============================================================
# 5. Fonts (skip on WSL — install these on the Windows host for Windows Terminal instead)
# =============================================================
if confirm "Install Nerd Fonts (Iosevka, RobotoMono, Meslo)?" "$(gui_default)"; then
  mkdir -p ~/.local/share/fonts/
  wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Iosevka.zip
  wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/RobotoMono.zip
  wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip
  unzip Iosevka.zip -d ~/.local/share/fonts/
  unzip RobotoMono.zip -d ~/.local/share/fonts/
  unzip Meslo.zip -d ~/.local/share/fonts
  rm Iosevka.zip RobotoMono.zip Meslo.zip
  fc-cache -fv
fi

# =============================================================
# 6. Neovim (built releases are newer than apt's package)
# =============================================================
if confirm "Install latest Neovim (official AppImage build)?" y; then
  NVIM_TMPDIR=$(mktemp -d)
  (
    cd "$NVIM_TMPDIR"
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
    chmod u+x nvim-linux-x86_64.appimage
    ./nvim-linux-x86_64.appimage --appimage-extract >/dev/null
    sudo rm -rf /opt/nvim
    sudo mv squashfs-root /opt/nvim
  )
  rm -rf "$NVIM_TMPDIR"
  sudo ln -sf /opt/nvim/AppRun /usr/bin/nvim
  # extracted once at install time, so no FUSE/libfuse2 needed at runtime — works on Kali/WSL too
fi

# =============================================================
# 7. Rust (single source of truth: rustup, not apt's cargo/rustc — always installed,
#    since sd/dust/eza-fallback/alacritty all depend on it)
# =============================================================
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
. "$HOME/.cargo/env"

if [[ "$NEED_EZA_FALLBACK" == "1" ]]; then
  cargo install eza
fi
cargo install sd
cargo install du-dust   # provides the `dust` binary (better du), not in apt

# =============================================================
# 8. Dotfiles
# =============================================================
cd ~
git clone https://github.com/sidd-sh/dotfiles
cd ~/dotfiles
stow tmux
stow nvim

INSTALL_ALACRITTY=0
if confirm "Install Alacritty terminal + stow its config?" "$(gui_default)"; then
  INSTALL_ALACRITTY=1
  stow alacritty
fi

if confirm "Install VS Code?" "$(gui_default)"; then
  wget "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" -O vscode.deb
  sudo dpkg -i ./vscode.deb
  rm vscode.deb
fi

if confirm "Install desktop GUI extras (Thunar, Flameshot, Papirus icon theme)?" "$(gui_default)"; then
  sudo apt install -y thunar flameshot papirus-icon-theme
fi

# =============================================================
# 9. Zsh + Oh My Zsh (always — this is the shell config the rest of the dotfiles assume)
# =============================================================
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autocomplete"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
git clone https://github.com/MichaelAquilina/zsh-you-should-use.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/you-should-use"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
rm -f ~/.zshrc
cd ~/dotfiles && stow zshrc

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# =============================================================
# 10. fzf (repo version is often stale/broken — always installed, keybinds depend on it)
# =============================================================
FZF_URL=$(curl -s https://api.github.com/repos/junegunn/fzf/releases/latest \
  | jq -r '.assets[] | select(.name | test("linux_amd64\\.tar\\.gz$")) | .browser_download_url')
wget "$FZF_URL" -O fzf.tar.gz
tar xvzf fzf.tar.gz
rm fzf.tar.gz
sudo mv fzf /usr/bin/fzf

curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh   # zoxide: better cd

# =============================================================
# 11. Misc CLI nice-to-haves (bundled — say no to skip all of these)
# =============================================================
if confirm "Install misc CLI nice-to-haves (termscp, pet, navi, s, termshot, himalaya)?" y; then
  curl --proto '=https' --tlsv1.2 -sSLf "https://git.io/JBhDb" | sh   # termscp: TUI for ftp/sftp/smb

  PET_URL=$(curl -s https://api.github.com/repos/knqyf263/pet/releases/latest \
    | jq -r '.assets[] | select(.name | test("linux_amd64\\.deb$")) | .browser_download_url')
  wget "$PET_URL" -O pet.deb
  sudo dpkg -i pet.deb
  rm pet.deb

  bash <(curl -sL https://raw.githubusercontent.com/denisidoro/navi/master/scripts/install)

  go install github.com/zquestz/s@latest

 # my fork of termshot
  wget https://github.com/sidd-sh/termshot/releases/latest/download/termshot -O termshot
  chmod +x termshot
  sudo mv termshot /usr/bin/termshot
  
  curl -sSL https://raw.githubusercontent.com/pimalaya/himalaya/master/install.sh | PREFIX=~/.local sh
fi

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# =============================================================
# 12. PowerShell + .NET (optional — niche, off by default)
# =============================================================
if confirm "Install PowerShell + .NET SDK?" n; then
  source /etc/os-release
  wget -q https://packages.microsoft.com/config/debian/"$VERSION_ID"/packages-microsoft-prod.deb
  sudo dpkg -i packages-microsoft-prod.deb
  rm packages-microsoft-prod.deb
  sudo apt update && sudo apt install -y powershell dotnet-sdk-9.0 aspnetcore-runtime-9.0
fi

# =============================================================
# 13. uv (replaces pipx entirely) + Python-based security tooling
# =============================================================
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"   # so `uv` is usable for the rest of this script

uv python install 3.11 3.12

if confirm "Install AD security tooling via uv (NetExec, BloodyAD, PowerView.py)?" y; then
  uv tool install git+https://github.com/Pennyw0rth/NetExec
  uv tool install bloodyAD
  uv tool install git+https://github.com/aniqfakhrul/powerview.py
fi

# =============================================================
# 14. Alacritty binary itself (only if you opted into it above)
# =============================================================
if [[ "$INSTALL_ALACRITTY" == "1" ]]; then
  cargo install alacritty
fi

chsh -s /usr/bin/zsh

echo ""
echo "Done. Log out and back in (or reboot) to pick up the docker group and default shell change."
