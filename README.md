# Description

This repository is heavily inspired from xct/kali-clean but contains a big overhaul based on my own configs in the dotfiles repo and changes to the installer script.

After cloning the repo just run ./install.sh from a non-root user. This updates kali and installs a lot of stuff, so it will take a while. Feel free to optimize ;)

## Installation

```
./install.sh
```

After the script is done reboot and select i3 (top right corner) on the login screen.

## Features
* Installs i3 and its configs (dotfiles/i3)
* Installs Alacritty and its configs (dotfiles/alacritty)
* Installs stow (so you can modify your own dotfiles and track them with git)
* Installs ZSH and its configs (dotfiles/zsh)
* Installs tmux and its configs (dotfiles/tmux)
* Installs starship and its configs (dotfiles/starship)
* Installs polybar and its configs (dotfiles/polybar)
* Installs rofi and its configs (dotfiles/rofi)
* Installs picom and its configs (dotfiles/picom)
* Installs nvim and its configs (dotfiles/nvim)
* Installs a few tools for my own use
* Installs a few useful fonts
* Installs a few libraries and useful utilities

## Credits
Inspired by xct/kali-clean and typecraft-dev/dotfiles

# Future Changes
* Potentially adding in a new login screen for kali
* Add more tools as I discover them which I might break out into a different script
