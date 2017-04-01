#! /usr/bin/env bash
set -e
# This script assumes it will be run as root from the ROOT_DIR on the devbox
# Don't call it directly, use the make system target
# When testing the script on the devbox itself, you might use: sudo su - -p -c 'make system'

# sync config file located in /vagrant
sync_extra_config () {
    local config_file=$1
    if [[ -f "/vagrant/${config_file}" ]]; then
        # Always override with the shared file
        echo "Overridding ${config_file}"
        if [[ -f "/etc/nixos/${config_file}" ]]; then
            cp --verbose "/etc/nixos/${config_file}" "/etc/nixos/${config_file}.back"
        fi
        cp --verbose "/vagrant/${config_file}" "/etc/nixos/${config_file}"
    else
        # when there is no custom config file, copy but don't override an existing installed configuration
        cp --verbose -n "./system/${config_file}" "/etc/nixos/${config_file}"
    fi
}

# Always override the main system configuration file
cp --verbose "./system/configuration.nix" "/etc/nixos/configuration.nix";

sync_extra_config "local-configuration.nix"
sync_extra_config "desktop-configuration.nix"

# Sync system custom nixpkgs files
rsync -av --chmod=644 ./system/pkgs/ /etc/cicd/

echo "Updating the system. Hold on. It might take a while (usually from 5 to 20 minutes)";
nixos-rebuild switch --upgrade > /vagrant/system_boot.log 2>&1 && echo "System configuration completed"
