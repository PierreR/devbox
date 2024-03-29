#! /usr/bin/env bash
set -euo pipefail
devbox_url="https://bitbucket.irisnet.be/scm/cicd/devbox.git"

script_dir="$(dirname -- "$(readlink -f -- "$0")")"

mount_dir="${1:-$SHARED_DIR}"
if [ ! -d "$mount_dir" ]; then
    _failure "${mount_dir} is not a directory. Please pass a valid ROOT_DIR"
    exit 1
fi

config_file="${mount_dir}/box.cue"
dhall_config_file="${mount_dir}/box.dhall"
if [ ! -f "$config_file" ] && [ ! -f "$dhall_config_file" ]; then
    echo "Add empty configuration in ${config_file}. Please fill in ${config_file} with your personal data."
    cp --verbose "${script_dir}/box-cirb.cue" "$config_file"
fi

local_config="${mount_dir}/local-home.nix"
if [ !  -f "$local_config" ]; then
    echo "Add ${local_config}. You might want to customize this user configuration file later."
    cp --verbose "${script_dir}/local-home.nix" "$local_config"
fi

{

# shellcheck source=/home/vagrant/bootstrap/utils.sh
source "$script_dir/../utils.sh"

# shellcheck source=/home/vagrant/bootstrap/version.sh
source "$script_dir/../version.sh"

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
        _failure "no ssh-keys directory found. You won't be able to push anything to bitbucket.irisnet.be"
    fi
}

check_connection() {
    if ! ping -c1 bitbucket.irisnet.be > /dev/null
    then
        _failure "No connexion to Bitbucket.\nBootstrap can't be realized. Abort user configuration."
        exit 1
    fi
}

bootstrap () {

    if [ ! -d "/home/vagrant/.config/vcsh/repo.d/dotfiles.git" ]; then # bootstrap: clone of the dotfiles repo in $HOME
        echo "About to use vcsh to clone ${devbox_url}"
        if vcsh clone -b "$release" "$devbox_url" dotfiles
        then
            _success "clone devbox ${release} from ${devbox_url}\n"
        else
            printf '\n'
            _failure "Bootstrap has failed ! Unable to clone ${devbox_url}.\nAborting user configuration."
            exit 1
        fi
    fi
}

install_hm () {
    nix-channel --update
    if hash home-manager >/dev/null 2>&1
    then
        printf 'Running the Home-manager ...\n'
        if home-manager switch >/dev/null 2>&1
        then
            _success "home-manager switch"
        else
            _failure "Type 'home-manager switch' to see what went wrong."
            exit 1
        fi
    else
        if nix-shell '<home-manager>' -A install -I "home-manager=https://github.com/rycee/home-manager/archive/release-${release}.tar.gz"
        then
            _success "home-manager installed.\n"
        else
            _failure "Unable to install the home-manager."
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
echo "Starting user configuration. Hold on."
check_connection
install_ssh_keys
bootstrap
install_hm
install_mr_repos

} | tee "${mount_dir}/user_lastrun.log"
