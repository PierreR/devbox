#! /usr/bin/env bash

dotfilesUrl="http://stash.cirb.lan/scm/devb/dotfiles.git"

script_dir="$(dirname -- "$(readlink -f -- "$0")")"

mount_dir="${1:-$SHARED_DIR}"
if [ ! -d "$mount_dir" ]; then
    _failure "${mount_dir} is not a directory. Please pass a valid ROOT_DIR"
    exit 1
fi

config_file="${mount_dir}/box.dhall"
if [ ! -f "$config_file" ]; then
    echo "Add empty configuration in ${config_file}. Please fill in ${config_file} with your personal data."
    cp --verbose "${script_dir}/box-cirb.dhall" "$config_file"
fi

local_config="${mount_dir}/local-home.nix"
if [ !  -f "$local_config" ]; then
    echo "Add ${local_config}. You might want to customize this user configuration file later."
    cp --verbose "${script_dir}/local-home.nix" "$local_config"
fi

{

# shellcheck source=/home/vagrant/bootstrap/utils.sh
source utils.sh

# shellcheck source=/home/vagrant/bootstrap/version.sh
source version.sh

set -u

install_ssh_keys () {
    printf 'Synchronizing ssh keys\n'
    local ssh_hostdir="${mount_dir}/ssh-keys"
    local guestdir="$HOME/.ssh"
    if [ -d "$ssh_hostdir" ]; then
        # rsync -i --chmod=644 ${ssh_hostdir}/*.pub "$guestdir"
        find "$ssh_hostdir" -type f -name "*.*" -exec rsync -ai --chmod=644 {} "$guestdir/" \;
        find "$ssh_hostdir" -type f ! -name "*.*" -exec rsync -ai --chmod=600 {} "$guestdir/" \;
        _success "install ssh keys"
    else
        _failure "no ssh-keys directory found. You won't be able to push anything to stash.cirb.lan."
    fi
}

# Cloning dotfiles repo (in a none empty dir)
# The clone will fail in case of file conflict
# We can fall back to this if vcsh causes issues
# vcsh is safer in case we need to delete 'dotfiles' as a result of an unfortunate crash
_clone_dotfiles() {
    local src_url="$1"
    local tgt_dir="$2"
    mkdir -p "${tgt_dir}/.config"
    pushd "$tgt_dir" >/dev/null 2>&1 || return
    git init --separate-git-dir="${tgt_dir}/.config/dotfiles"
    git remote add origin "$src_url"
    git remote add nixpkgs ssh://git@stash.cirb.lan:7999/cicd/nixpkgs.git
    git fetch --depth=1 origin master
    git checkout -b master --track origin/master
    git config core.excludesfile .gitignore.d/dotfiles
    git config alias.pull-nixpkgs "subtree pull --prefix .config/nixpkgs nixpkgs master --squash"
    git config alias.push-nixpkgs "subtree push --prefix .config/nixpkgs nixpkgs master --squash"
    git update-index --skip-worktree .mrconfig
    popd || return
}

_clone () {
    local url=$1
    if ! ping -c1 stash.cirb.lan > /dev/null
    then
        echo "No connexion to stash.\nBootstrap can't be realized. Abort user configuration."
        exit 1
    fi
    if hash vcsh >/dev/null 2>&1
    then
        echo "About to use vcsh to clone ${url}"
        vcsh clone -b "$version" "$url" dotfiles
    else
        echo "Using cloning routine to clone ${url}"
        _clone_dotfiles "$url" "$HOME"
    fi
}

bootstrap_hm () {

    if [ ! -d "/home/vagrant/.config/vcsh/repo.d/dotfiles.git" ]; then # bootstrap: clone of the dotfiles repo in $HOME
        if [ -z "$dotfilesUrl" ]
        then
            _failure "In box.dhall, 'dotfilesUrl' is empty.\nBootstrap can't be realized. Abort user configuration."
            exit 1
        else
            if _clone "$dotfilesUrl"
            then
                _success "clone mr ${dotfilesUrl}\n"
                if nix-shell '<home-manager>' -A install -I "home-manager=https://github.com/rycee/home-manager/archive/release-${release}.tar.gz"
                then
                    _success "home-manager installed.\n"
		    nix-channel --update
                else
                    _failure "Unable to install the home-manager."
                    exit 1
                fi
            else
                printf '\n'
                _failure "Bootstrap has failed ! Unable to clone ${dotfilesUrl}.\nAborting user configuration."
                exit 1
            fi
        fi
    else # No in bootstrap
	    printf 'Running the Home-manager ...\n'
        if home-manager switch >/dev/null 2>&1
        then
            _success "home-manager switch"
        else
            _failure "Type 'home-manager switch' to see what went wrong."
            exit 1
        fi
    fi
}


install_mr_repos () {
    if mr -d "$HOME" up -q
    then
        _success "mr"
    else
        _failure "mr"
    fi
}

# Main

install_ssh_keys
bootstrap_hm
install_mr_repos

} | tee "${mount_dir}/user_lastrun.log"
