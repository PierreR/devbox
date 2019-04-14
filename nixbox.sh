#! /usr/bin/env nix-shell
#! nix-shell -i bash -p dhall-bash

script_dir="$(dirname -- "$(readlink -f -- "$0")")"

source "$script_dir/utils.sh"

config_file=$1
if [ ! -f "$config_file" ]; then
    _failure "please pass the path to a valid dhall configuration file as first argument. Can't find ${config_file}."
    exit 1
fi

eval $(dhall-to-bash --declare mount_dir <<< "($config_file).mountDir")

dest_dir="${mount_dir}/nixbox"
if [ ! -d "$dest_dir"  ]; then
  echo "Cloning nixbox."
  git clone https://github.com/nix-community/nixbox.git "$dest_dir"
fi

dest_script_dir="${dest_dir}/scripts"
cp "${script_dir}/system/custom-configuration.nix" "$dest_script_dir"
cp "${script_dir}/system/local-configuration.nix" "$dest_script_dir"
cp "${script_dir}/system/desktop-tiling-configuration.nix" "$dest_script_dir"

append=\
'curl -sf "$packer_http/local-configuration.nix" > /mnt/etc/nixos/local-configuration.nix  \
curl -sf "$packer_http/desktop-tiling-configuration.nix" > /mnt/etc/nixos/desktop-tiling-configuration.nix
'

dest_install_script="${dest_script_dir}/install.sh"
if ! grep -q "local-configuration" "$dest_install_script";  then
 echo "Append local and desktop to the install script."
 sed -i "/^curl -sf.*custom-configuration.nix.*/a ${append}" "$dest_install_script"
fi
