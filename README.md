# fedora
A fedora installation

# gnome settings backup
```shell
dconf dump / > gnome-settings-backup.txt
```

# gnome settings restore
```shell
dconf load / < gnome-settings-backup.txt
```

# installed packages
```shell
git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autocomplete
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

# install oh-my-zsh
```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

# packages
```shell
sudo dnf install fzf stow hyfetch exa kitty neovim gnome-shell-extension-pop-shell akmod-nvidia nvidia-smi xorg-x11-drv-nvidia-cuda -y
```

# kickstart neovim
```shell
git clone https://github.com/nvim-lua/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
```
