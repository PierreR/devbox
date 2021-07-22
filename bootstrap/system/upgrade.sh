#!/usr/bin/env bash
set -xeu
vcsh run dotfiles git fetch
vcsh run dotfiles git co 21.05
vcsh dotfiles pull --quiet --rebase --ff-only
nix-channel --update
sudo bash -c "curl https://bitbucket.irisnet.be/projects/CICD/repos/devbox/raw/bootstrap/nixbox/scripts/configuration.nix?at=refs%2Fheads%2F21.05 > /etc/nixos/configuration.nix"
sudo sed -i "s/20.09/21.05/" /vagrant/local-configuration.nix
sudo /home/vagrant/bootstrap/system/setenv.sh
reboot
