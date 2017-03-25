#! /usr/bin/env bash
set -e
# This script assumes it will be run as root from the ROOT_DIR on the devbox
# Don't call it directly, use the make system target
# When testing the script on the devbox itself, you might use: sudo su - -p -c 'make system'

# Always override the main system configuration file
cp --verbose "./system/configuration.nix" "/etc/nixos/configuration.nix";

if [[ -f "/vagrant/local-configuration.nix" ]]; then
  # Always override with the shared file ?
  echo "Overridding local-configuration."
  if [[ -f "/etc/nixos/local-configuration.nix" ]]; then
    cp --verbose "/etc/nixos/local-configuration.nix" "/etc/nixos/local-configuration.back"
  fi
  cp --verbose "/vagrant/local-configuration.nix" "/etc/nixos/local-configuration.nix"
else
  # Don't override the local system configuration
  cp --verbose -n "./system/local-configuration.nix" "/etc/nixos/local-configuration.nix"
fi
# Sync system custom nixpkgs files
rsync -av --chmod=644 ./system/pkgs/ /etc/cicd/

echo "Updating the system. Hold on. It might take a while (usually from 5 to 20 minutes)";
nixos-rebuild switch --upgrade > /dev/null 2>&1 && echo "\nSystem configuration completed\n"
