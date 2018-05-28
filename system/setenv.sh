#! /usr/bin/env bash
set -e
# This script assumes it will be run as root from the ROOT_DIR on the devbox
# Don't call it directly, use the make system target
# When testing the script on the devbox itself, you might use: sudo su - -p -c 'make system'

# sync config file located in /vagrant
sync_extra_config () {
    local config_file=$1
    if [[ -f "/etc/nixos/${config_file}" ]]; then
        cp --verbose "/etc/nixos/${config_file}" "/etc/nixos/${config_file}.back"
    fi
    if [[ -f "/vagrant/${config_file}" ]]; then
        echo "Overridding ${config_file} using your personal configuration from the ROOT_DIR"
        cp --verbose "/vagrant/${config_file}" "/etc/nixos/${config_file}"
    else
        echo "No personal configuration found. Overridding ${config_file} using the devbox source repository"
        cp --verbose "./system/${config_file}" "/etc/nixos/${config_file}"
    fi
}

# Always override the main system configuration file
cp --verbose "./system/configuration.nix" "/etc/nixos/configuration.nix";

sync_extra_config "local-configuration.nix"
sync_extra_config "desktop-configuration.nix"
sync_extra_config "desktop-gnome-configuration.nix"


# Sync system custom nixpkgs files
rsync -av --chmod=644 ./system/pkgs/ /etc/cicd/

echo "Updating the system. Hold on. It might take a while (usually from 5 to 20 minutes)";
nixos-rebuild switch > /vagrant/system_boot.log 2>&1 && echo "System configuration completed"
