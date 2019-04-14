#! /usr/bin/env nix-shell
#! nix-shell -i bash -p rsync vcsh dhall-bash


script_dir="$(dirname -- "$(readlink -f -- "$0")")"

source "$script_dir/utils.sh"

config_file=$1
if [ ! -f "$config_file" ]; then
    _failure "please pass the path to a valid dhall configuration file as first argument. Can't find ${config_file}."
    exit 1
fi

if [ "$2" == 'sync' ]
then
    sync=true
else
    sync=false
fi

set -euo pipefail

eval $(dhall-to-bash --declare mount_dir <<< "($config_file).mountDir")

sync_extra_config () {
    local config=$1
    if [[ -f "${mount_dir}/${config}" ]]; then
        if [[ -f "/etc/nixos/${config}" ]]; then
            cp --verbose "/etc/nixos/${config}" "/etc/nixos/${config}.back"
        fi
        echo "Overridding ${config} using your personal configuration from ${mount_dir}"
        cp --verbose "${mount_dir}/${config}" "/etc/nixos/${config}"
    else
        if ! $sync
        then
            echo "No personal configuration found. Overridding ${config} using the devbox source repository"
            cp --verbose "${script_dir}/${config}" "/etc/nixos/${config}"
        fi
    fi
}

# Always override the packer custom-configuration file
if ! $sync
then
  cp --verbose "${script_dir}/custom-configuration.nix" "/etc/nixos/custom-configuration.nix";
  cp --verbose "${script_dir}/puppetdb-dns.nix" "/etc/nixos/puppetdb-dns.nix";
else
  echo "About to sync files."
fi

sync_extra_config "local-configuration.nix"
sync_extra_config "desktop-tiling-configuration.nix"
sync_extra_config "desktop-gnome-configuration.nix"
sync_extra_config "desktop-kde-configuration.nix"

# Create a symbolic link to ensure compatibility with older version temporary
# first remove the old desktop-configuration.nix file
rm -f /etc/nixos/desktop-configuration.nix
ln -s /etc/nixos/desktop-tiling-configuration.nix /etc/nixos/desktop-configuration.nix

# Sync system custom nixpkgs files
rsync -qav --chmod=644 "${script_dir}/pkgs/" /etc/cicd/

set +e
echo "Updating ..."
/usr/bin/env time -f "Completed after %E min" nixos-rebuild switch > "${mount_dir}/system_boot.log" 2>&1
if [ $? = 0 ]; then
    _success "system configuration completed."
else
    _failure "system configuration failure, check system_boot.log in your ROOT_DIR."
fi
