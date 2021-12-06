#!/bin/sh -e

packer_http=$(cat .packer_http)

# Partition disk
cat <<FDISK | fdisk /dev/sda
n




a
w

FDISK

# Create filesystem
mkfs.ext4 -j -L nixos /dev/sda1

echo "Mount filesystem"
mount LABEL=nixos /mnt

echo "Setup system"
nixos-generate-config --root /mnt

curl -sf "$packer_http/vagrant.nix" > /mnt/etc/nixos/vagrant.nix
curl -sf "$packer_http/vagrant-hostname.nix" > /mnt/etc/nixos/vagrant-hostname.nix
curl -sf "$packer_http/vagrant-network.nix" > /mnt/etc/nixos/vagrant-network.nix
curl -sf "$packer_http/builders/$PACKER_BUILDER_TYPE.nix" > /mnt/etc/nixos/hardware-builder.nix
curl -sf "$packer_http/configuration.nix" > /mnt/etc/nixos/configuration.nix
curl -sf "$packer_http/custom-configuration.nix" > /mnt/etc/nixos/custom-configuration.nix
curl -sL "https://bitbucket.irisnet.be/rest/api/latest/projects/CICD/repos/devbox/archive?format=tgz&at=v21.11.0" | tar xz --one-top-level=devbox-21.11.0 -C /mnt/etc

echo "Install"
nixos-install

echo "Cleaning up"
curl "$packer_http/postinstall.sh" | nixos-enter
