#!/usr/bin/env bash
set -eux
export RELEASE="21.11"
sudo mkdir -p -m 0755 /nix && sudo chown -R $USER /nix
command -v nix >/dev/null 2>&1 || sh <(curl -L https://releases.nixos.org/nix/nix-2.5.1/install) --no-daemon
. "$HOME/.nix-profile/etc/profile.d/nix.sh"
test -d devbox || git clone https://bitbucket.irisnet.be/scm/cicd/devbox.git
git -C devbox checkout "${RELEASE}"
git -C devbox pull
cp devbox/.nix-channels ~
nix-channel --update
grep -qF 'NIX_PATH' ~/.profile || echo "export NIX_PATH=$HOME/.nix-defexpr/channels:nixpkgs=/nix/var/nix/profiles/per-user/$USER/channels/nixos:nixpkgs-overlays=https://bitbucket.irisnet.be/CICD/nixpkgs-overlays/archive/${RELEASE}.tar.gz" >> ~/.profile
source ~/.profile
mkdir -p ~/.config/nix
cp devbox/.config/nix/nix.conf ~/.config/nix
sudo rsync -av --include '*.crt' --exclude '*' devbox/bootstrap/system/ /usr/local/share/ca-certificates/
sudo update-ca-certificates
command -v home-manager >/dev/null 2>&1 || nix-shell '<home-manager>' -A install -I "home-manager=https://github.com/rycee/home-manager/archive/release-${RELEASE}.tar.gz"
rsync -av devbox/.config/nixpkgs/modules/ ~/.config/nixpkgs/modules/
envsubst < devbox/bootstrap/user/wsl.nix.tmpl > ~/.config/nixpkgs/home.nix
home-manager switch
grep -qF 'direnv' ~/.bashrc || echo 'eval "$($HOME/.nix-profile/bin/direnv hook bash)"' >> ~/.bashrc
source ~/.bashrc
