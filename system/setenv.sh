#! /usr/bin/env bash
set -euo pipefail

# OUTPUT-COLORING
red='\e[0;31m'
green='\e[0;32m'
NC='\e[0m' # No Color

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
cp --verbose "./system/puppetdb-dns.nix" "/etc/nixos/puppetdb-dns.nix";

sync_extra_config "local-configuration.nix"
sync_extra_config "desktop-tiling-configuration.nix"
sync_extra_config "desktop-gnome-configuration.nix"
sync_extra_config "desktop-kde-configuration.nix"


# Sync system custom nixpkgs files
rsync -qav --chmod=644 ./system/pkgs/ /etc/cicd/

echo "Updating the system. Hold on. It might take several minutes.";
set +e
/usr/bin/env time -f "Completed after %E min" nixos-rebuild switch > /vagrant/system_boot.log 2>&1
if [ $? = 0 ]; then
    echo -e "${green}Done${NC}: system configuration completed."
else
    echo -e "${red}Error${NC}: system configuration failure, check system_boot.log in your ROOT_DIR."
fi
