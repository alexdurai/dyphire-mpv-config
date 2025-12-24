#!/bin/bash

set -eo pipefail

TMP_DIR="/tmp/dyphire-mpv-config"
GITHUB_REPO=https://github.com/alexdurai/dyphire-mpv-config
mode=remote


# Parse KEY=VALUE argument
for ARGUMENT in "$@"; do
    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)
    export "$KEY"="$VALUE"
done

mode="${mode,,}"   # convert to lowercase (bash 4+)

if [[ -z "$mode" ]]; then
    echo "Setting install from remote"
    mode="remote"
    elif [[ "$mode" != "local" && "$mode" != "remote" ]]; then
    echo "Error: mode must be 'local' or 'remote'"
    exit 1
fi


# Installer for MPV with custom configurations and context menu integration similar to Potplayer.

SCRIPT_ROOT="$(dirname "$(readlink -f "$0")")"

source "$SCRIPT_ROOT/.functions.sh"

detect_installer

echo "==> Installing dependencies..."

install_pkg_list "dependencies" || {
    echo "Failed to install dependencies for MPV. OS: $OS_NAME"
    exit 1
}

rm -rf ~/.config/mpv/*
mkdir -p $TMP_DIR
mode="${mode,,}"

if [ $mode != "local" ] || [ -z $mode ]; then
    echo  "Setting install from remote $GITHUB_REPO"
    rm -rf ~/.config/mpv/* && git clone ${GITHUB_REPO} $TMP_DIR

else
    echo  "Setting install from local"
    rsync -aHa \
    --exclude='install.sh' \
    --exclude='README.md' \
    --exclude='LICENSE.md' \
    . ~/.config/mpv
fi

echo "Installation complete"

#cp -r config/mpv/mpv.conf "$HOME/.config/mpv/"
#cp -r config/mpv/mpv.conf "$HOME/.config/mpv/"