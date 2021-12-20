#!/usr/bin/env bash
set -xeu
vcsh run dotfiles git fetch
vcsh run dotfiles git co 21.11
vcsh dotfiles pull --quiet --rebase --ff-only
nix-channel --update
cat <<EOF | sudo tee /root/.nix-channels
https://github.com/nix-community/home-manager/archive/6ce1d64073f48b9bc9425218803b1b607454c1e7.tar.gz home-manager
https://releases.nixos.org/nixos/21.11/nixos-21.11.334139.1bd4bbd49be/nixexprs.tar.xz nixpkgs
https://releases.nixos.org/nixos/21.11/nixos-21.11.334139.1bd4bbd49be/nixexprs.tar.xz nixos
EOF
sudo nix-channel --update
sudo bash -c "curl https://bitbucket.irisnet.be/projects/CICD/repos/devbox/raw/bootstrap/nixbox/scripts/configuration.nix?at=refs%2Fheads%2F21.11 > /etc/nixos/configuration.nix"
test -f /vagrant/local-configuration.nix && sudo sed -i "s/21.05/21.11/" /vagrant/local-configuration.nix
sudo /home/vagrant/bootstrap/system/setenv.sh
sudo reboot
