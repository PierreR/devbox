#! /usr/bin/env bash

script_dir="$(dirname -- "$(readlink -f -- "$0")")"

source "$script_dir/../utils.sh"

shared_dir="${1:-$SHARED_DIR}"

echo "Starting system configuration using shared dir: ${shared_dir}"

set -euo pipefail

sync_extra_config () {
    local config=$1
    local mounted_config="${shared_dir}/${config}"
    local vm_config="/etc/nixos/${config}"
    if [[ -n "$shared_dir" ]] && [[ -f $mounted_config ]]; then
        echo "Sync ${mounted_config}"
        _sync $mounted_config $vm_config
    else
        local script_config="${script_dir}/${config}"
        echo "No personal configuration found. Sync ${script_config}"
        _sync "${script_config}" "${vm_config}"
    fi

}

sync_extra_config "custom-configuration.nix"
sync_extra_config "local-configuration.nix"

set +e
echo "Updating ..."
if [[ -d "$shared_dir"  ]] ; then
    /usr/bin/env time -f "Completed after %E min" nixos-rebuild switch > "${shared_dir}/system_boot.log" 2>&1
else
    /usr/bin/env time -f "Completed after %E min" nixos-rebuild switch
fi

if [ $? = 0 ]; then
    _success "system configuration completed."
else
    _failure "system configuration failure, check system_boot.log in your ROOT_DIR."
fi
