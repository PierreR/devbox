#! /usr/bin/env bash

version="19.09.1"
scm_uri="https://github.com/cirb/devbox/archive/${version}.tar.gz"

script_dir="$(dirname -- "$(readlink -f -- "$0")")"

source "$script_dir/utils.sh"

mount_dir=$1
if [ ! -d "$mount_dir" ]; then
    _failure "please pass the path to a valid mounted shared directory."
    exit 1
fi

dest_dir="${mount_dir}/nixbox"
if [ ! -d "$dest_dir"  ]; then
  echo "Cloning nixbox."
  git clone -b 19.09 https://github.com/nix-community/nixbox.git "$dest_dir"
fi

dest_script_dir="${dest_dir}/scripts"
cp "${script_dir}/system/CIRB_CIBG_ROOT_PKI.crt" "$dest_script_dir"

bootstrap="curl -sL ${scm_uri} | tar xz -C /mnt/etc"
append=\
'curl -sf "$packer_http/CIRB_CIBG_ROOT_PKI.crt" > /mnt/etc/nixos/CIRB_CIBG_ROOT_PKI.crt\
'
append+=$bootstrap

dest_install_script="${dest_script_dir}/install.sh"
if ! grep -q "local-configuration" "$dest_install_script";  then
 echo "Append local and desktop to the install script."
 sed -i "/^curl -sf.*custom-configuration.nix.*/a ${append}" "$dest_install_script"
fi
