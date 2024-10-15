# fedora
A fedora installation

# gnome settings backup
dconf dump / > gnome-settings-backup.txt

# gnome settings restore
dconf load / < gnome-settings-backup.txt

# installed packages
git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autocomplete
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# packages
sudo dnf install fzf stow hyfetch exa kitty neovim gnome-shell-extension-pop-shell akmod-nvidia nvidia-smi xorg-x11-drv-nvidia-cuda -y
