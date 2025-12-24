#!/bin/bash


FEDORA_DISTROS=("Fedora" "Nobara" "CentOS" "Fedora Silverblue")
FEDORA_ATOMIC_DISTROS=("Fedora Atomic Host" "Fedora CoreOS" "Bazite" "Silverblue" "Ultramarine")
DEBIAN_DISTROS=("Ubuntu" "Mint" "Debian" "Pop" "Lite")
ARCH_DISTROS=("Arch" "Manjaro" "EndeavourOS" "Garuda" "RebornOS" "ArcoLinux" "CachyOS")
OPEN_SUSE_DISTROS=("openSUSE Leap" "openSUSE Tumbleweed")
ALPINE_DISTROS=("Alpine Linux")
SCRIPT_ROOT="$(dirname "$(readlink -f "$0")")"
LISTS_ROOT="$SCRIPT_ROOT/lists"


get_os_name() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "${PRETTY_NAME:-$NAME}"
    else
        uname -s
    fi
}


os_matches() {
    local os="$1"; shift
    local distro
    
    for distro in "$@"; do
        [[ "$os" == *"$distro"* ]] && return 0
    done
    return 1
}

detect_installer() {
    OS_NAME="$(get_os_name)"
    
    if os_matches "$OS_NAME" "${FEDORA_ATOMIC_DISTROS[@]}"; then
        echo "==> Detected Fedora Atomic based OS: $OS_NAME"
        DISTRO_BASE="fedora-atomic"
        INSTALLER="rpm-ostree install -y"
        PKG_LIST="$LISTS_ROOT/apps_fedora.lst"
        
        elif os_matches "$OS_NAME" "${FEDORA_DISTROS[@]}"; then
        echo "==> Detected Fedora based OS: $OS_NAME"
        DISTRO_BASE="fedora"
        INSTALLER="sudo dnf install -y"
        PKG_LIST="$LISTS_ROOT/apps_fedora.lst"
        
        elif os_matches "$OS_NAME" "${DEBIAN_DISTROS[@]}"; then
        echo "==> Detected Debian based OS: $OS_NAME"
        DISTRO_BASE="debian"
        INSTALLER="sudo apt install -y"
        PKG_LIST="$LISTS_ROOT/apps_debian.lst"
        
        elif os_matches "$OS_NAME" "${ARCH_DISTROS[@]}"; then
        echo "==> Detected Arch based OS: $OS_NAME"
        DISTRO_BASE="arch"
        INSTALLER="sudo pacman -S --noconfirm"
        PKG_LIST="$LISTS_ROOT/apps_arch.lst"
        
        elif os_matches "$OS_NAME" "${OPEN_SUSE_DISTROS[@]}"; then
        echo "==> Detected openSUSE based OS: $OS_NAME"
        DISTRO_BASE="opensuse"
        INSTALLER="sudo zypper install -y"
        PKG_LIST="$LISTS_ROOT/apps_opensuse.lst"
        elif os_matches "$OS_NAME" "${ALPINE_DISTROS[@]}"; then
        DISTRO_BASE="alpine"
        echo "==> Detected Alpine OS: $OS_NAME"
        INSTALLER="sudo apk add"
        PKG_LIST="$LISTS_ROOT/apps_alpine.lst"
    else
        echo "==> Unsupported OS: $OS_NAME"
        return 1
    fi
}

install_pkg_list() {
    list_type="$1"
    detect_installer || {
        echo "Failed to detect installer for OS: $OS_NAME"
        return 1
    }
    
    PKG_LIST="$LISTS_ROOT/${list_type}_${DISTRO_BASE}.lst"
    echo "Installing packages from list: $PKG_LIST"
    
    while IFS= read -r pkg || [[ -n "$pkg" ]]; do
        
        
        # Skip empty lines and comments
        [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
        
        if ! rpm -q "$pkg" &>/dev/null; then
            to_install+=("$pkg")
        fi
    done < "$PKG_LIST"
    
    if [ ${#to_install[@]} -eq 0 ]; then
        echo "All packages from $PKG_LIST are already installed."
    else
        echo "Installing missing packages: ${to_install[*]}"
        $INSTALLER "${to_install[@]}"
    fi
    
}