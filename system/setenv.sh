#! /usr/bin/env nix-shell
#! nix-shell -i bash -p rsync vcsh dhall-bash

script_dir="$(dirname -- "$(readlink -f -- "$0")")"

source "$script_dir/../utils.sh"

config_file=$1
if [ ! -f "$config_file" ]; then
    _failure "please pass the path to a valid dhall configuration file as first argument. Can't find ${config_file}."
    exit 1
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
        local sync_config="${script_dir}/${config}"
        echo "No personal configuration found. Syncing ${sync_config}"
        rsync -ai --chmod=644 "${sync_config}" "/etc/nixos/${config}"
    fi
}

sync_extra_config "custom-configuration.nix"

rsync -qav --chmod=644 "${script_dir}/nix/" /etc/nixos/
rsync -ai --chmod=644 "${script_dir}/lorri.nix" /etc/nixos/lorri.nix

set +e
echo "Updating ..."
/usr/bin/env time -f "Completed after %E min" nixos-rebuild switch > "${mount_dir}/system_boot.log" 2>&1
if [ $? = 0 ]; then
    _success "system configuration completed."
else
    _failure "system configuration failure, check system_boot.log in your ROOT_DIR."
fi
