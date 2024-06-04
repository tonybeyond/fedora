#!/bin/bash

# Exit on error, treat unset variables as an error.
set -eu

# Define variables
DOWNLOADS_PATH="$HOME/Downloads"

# Enable dry run mode if desired
DRY_RUN=false
if [[ "${1-}" == "--dry-run" ]]; then
    DRY_RUN=true
    echo "Dry run mode enabled. No changes will be made."
fi

# Detect the operating system
OS=""
if [ -f /etc/fedora-release ]; then
    OS="fedora"
else
    echo "This script only supports Fedora."
    exit 1
fi

# Function to log errors
log_error() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - ERROR: $1" >> install.log
}

# Function to check if a package is installed
is_package_installed() {
    rpm -q "$1" &> /dev/null
}

# Define package lists
required_packages=(
    "gnome-tweaks" "btop" "neofetch" "flameshot" "xclip" "git"
    "gimagereader" "tesseract" "tesseract-langpack-fra" "tesseract-langpack-eng"
    "gnome-shell-extension-appindicator" "terminator" "gnome-shell-extension-manager"
    "curl" "wget" "make" "typescript" "bat" "eza"
    "vlc" "nextcloud-client" "unzip" "remmina" "fd-find" "fzf" "neovim" "gnome-shell-extension-pop-shell" "freerdp"
)

# Function to install required packages
install_required_packages() {
    echo "Installing required packages..."
    local failed_packages=()
    for package in "${required_packages[@]}"; do
        echo "Checking if $package is installed..."
        if ! is_package_installed "$package"; then
            echo "Installing $package..."
            $DRY_RUN || sudo dnf install -y "$package" || failed_packages+=("$package")
        fi
    done

    if [ ${#failed_packages[@]} -gt 0 ]; then
        log_error "Failed to install the following packages: ${failed_packages[*]}"
    fi
}

# Function to install ZSH and Oh My Zsh
install_zsh_ohmyzsh() {
    if ! is_package_installed zsh; then
        echo "Installing ZSH..."
        $DRY_RUN || sudo dnf install -y zsh || log_error "Failed to install zsh"
    fi

    echo "Installing Oh My Zsh..."
    $DRY_RUN || sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || log_error "Failed to install Oh My Zsh"

    # Set default shell to ZSH
    $DRY_RUN || chsh -s $(which zsh)
}

# Function to configure Oh My Zsh
configure_ohmyzsh() {
    echo "Configuring Oh My Zsh..."
    ZSHRC="$HOME/.zshrc"
    $DRY_RUN || sed -i 's/^ZSH_THEME=.*/ZSH_THEME="agnoster"/' "$ZSHRC"
    $DRY_RUN || sed -i 's/^plugins=.*/plugins=(git vscode z fzf fd)/' "$ZSHRC"
}

# Function to install Brave Browser
install_brave_browser() {
    if ! is_package_installed brave-browser; then
        echo "Installing Brave Browser..."
        $DRY_RUN || sudo dnf install -y dnf-plugins-core
        $DRY_RUN || sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
        $DRY_RUN || sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
        $DRY_RUN || sudo dnf install -y brave-browser || log_error "Failed to install Brave Browser"
    fi
}

# Function to install virtualization tools
install_virtualization() {
    echo "Installing virtualization tools..."
    $DRY_RUN || sudo dnf install -y @virtualization
    $DRY_RUN || sudo systemctl start libvirtd
    $DRY_RUN || sudo systemctl enable libvirtd
    $DRY_RUN || sudo usermod -aG libvirt "$(whoami)"
}

add_dracula_theme () {
    cd "$DOWNLOADS_PATH"
    echo "Adding Dracula theme to GNOME Terminal..."
    if [ ! -d "gnome-terminal" ]; then
        git clone https://github.com/dracula/gnome-terminal || log_error "Failed to clone Dracula GNOME Terminal repository"
    fi
    cd gnome-terminal || log_error "Failed to change directory to gnome-terminal"
    ./install.sh || log_error "Failed to install Dracula GNOME Terminal theme"
}

# Function to install Flatpak packages
install_flatpak_packages() {
    echo "Installing Flatpak packages..."
    $DRY_RUN || flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    FLATPAK_PACKAGES=("com.parsecgaming.parsec" "md.obsidian.Obsidian" "org.nextcloud.Nextcloud" "com.visualstudio.code")
    
    for package in "${FLATPAK_PACKAGES[@]}"; do
        echo "Installing $package..."
        $DRY_RUN || flatpak install -y flathub "$package" || log_error "Failed to install $package"
    done
}

# Function to install Nerd Fonts
install_nerd_fonts () {
    echo "Installing Nerd Fonts..."
    cd "$DOWNLOADS_PATH" || log_error "Failed to change directory to $DOWNLOADS_PATH"

    if [ ! -d "nerd-fonts" ]; then
        git clone https://github.com/ryanoasis/nerd-fonts.git --depth=1 || log_error "Failed to clone Nerd Fonts repository"
    fi

    cd nerd-fonts || log_error "Failed to change directory to nerd-fonts"
    ./install.sh || log_error "Failed to install Nerd Fonts"
}

# Main installation function
main_installation() {
    echo "Starting installation..."
    install_required_packages
    install_nerd_fonts
    install_brave_browser
    install_virtualization
    add_dracula_theme
    install_flatpak_packages
    install_zsh_ohmyzsh
    configure_ohmyzsh
}

# Ensure the script is running with sudo privileges
if ! sudo -n true 2>/dev/null; then
    echo "This script requires sudo privileges to run. Please enter your password:"
    sudo -v
fi

# Run the main installation function
main_installation

if [ "$DRY_RUN" = false ]; then
    # Reboot the system
    echo "Rebooting system..."
    sudo reboot
else
    echo "Dry run completed. No changes were made."
fi
