#! /usr/bin/env bash

hash dhall-to-bash 2>/dev/null || { echo >&2 "The script requires dhall-to-bash but it's not installed.  Aborting."; exit 1; }

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
    git fetch --depth=1 origin master
    git checkout -b master --track origin/master
    git config core.excludesfile .gitignore.d/dotfiles
    git update-index --skip-worktree .mrconfig
    popd || return
}

_clone () {
    local url=$1
    if hash vcsh >/dev/null 2>&1
    then
        echo "About to use vcsh to clone ${url}"
        vcsh "$url" dotfiles
    else
        echo "Using cloning routine to clone ${url}"
        _clone_dotfiles "$url" "$HOME"
    fi
}

bootstrap_hm () {

    if [ ! -d "/home/vagrant/.config/vcsh/repo.d/dotfiles.git" ]; then # bootstrap: clone of the dotfiles repo in $HOME
        eval $(dhall-to-bash --declare DOTFILES_URL <<< "($config_file).dotfilesUrl")
        if [ -z "$DOTFILES_URL" ]
        then
            _failure "In box.dhall, 'dotfilesUrl' is empty.\nBootstrap can't be realized. Abort user configuration."
            exit 1
        else
            if _clone "$DOTFILES_URL"
            then
                _success "clone mr ${DOTFILES_URL}\n"
                if nix-shell '<home-manager>' -A install
                then
                    _success "home-manager installed.\n"
                else
                    _failure "Unable to install the home-manager."
                    exit 1
                fi
            else
                printf '\n'
                _failure "Bootstrap has failed ! Unable to clone ${DOTFILES_URL}.\nAborting mr configuration."
                return 1
            fi
        fi
    else # No in bootstrap
	    printf 'Running the Home-manager ...\n'
        if home-manager switch >/dev/null 2>&1
        then
            _success "home-manager switch"
        else
            _failure "home-manager switch"
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

install_doc () {
    printf 'Installing doc.\n'
    if make doc outdir="$HOME/.local/share/devbox">/dev/null 2>&1
    then
        _success "documentation."
    else
        _failure "documentation not installed successfully."
    fi
}

# Install eclipse plugin that are not part of nixpkgs or home-manager
install_extra_eclipse_plugin () {
    full_name="$1"
    repository="$2"
    installUI="$3"
    printf "About to download Eclipse plugin %s. Hold on.\\n" "$full_name"

    if eclipse -application "org.eclipse.equinox.p2.director" \
               -repository "${repository}" \
               -installIU "${installUI}" \
               -profile "SDKProfile" \
               -profileProperties "org.eclipse.update.install.features=true" \
               -p2.os "linux" \
               -p2.arch "x86" \
               -roaming -nosplash \
               >/dev/null 2>&1
    then
        printf 'Eclipse plugin %s has been successfully downloaded\n' "$full_name"
    else
        printf 'Failed to download Eclipse plugin %s \n' "$full_name"
    fi
}


# Main

install_ssh_keys
bootstrap_hm
install_mr_repos
install_doc

with_eclipse=$(dhall-to-bash <<< "($config_file).eclipse")

if "$with_eclipse"
then
    eclipse_version_name="2018-12"
    install_extra_eclipse_plugin "org.eclipse.egit" "http://download.eclipse.org/releases/${eclipse_version_name}/" "org.eclipse.egit.feature.group"
    install_extra_eclipse_plugin "org.eclipse.m2e" "http://download.eclipse.org/releases/${eclipse_version_name}/" "org.eclipse.m2e.feature.feature.group"
fi

} | tee "${mount_dir}/user_lastrun.log"
