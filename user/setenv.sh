#! /usr/bin/env nix-shell
#! nix-shell -i bash -p dhall-bash

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

source utils.sh

set -eu


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
_clone_dotfiles() {
    local src_url="$1"
    local tgt_dir="$2"
    mkdir -p "${tgt_dir}/.config"
    pushd $tgt_dir >/dev/null 2>&1
    git init --separate-git-dir="${tgt_dir}/.config/dotfiles"
    git remote add origin $src_url
    git fetch --depth=1 origin master
    git checkout -b master --track origin/master
    git config core.excludesfile .gitignore.d/dotfiles
    git update-index --skip-worktree .mrconfig
    popd
}

install_mr_repos () {
    set +e
    printf 'Installing mr repos\n'
    declare bootstrap=false
    if [ ! -f "$HOME/.mrconfig" ]; then
        bootstrap=true
        # bootstrap: clone of the dotfiles repo in $HOME
        eval $(dhall-to-bash --declare dotfiles_url <<< "($config_file).dotfilesUrl")
        if [ -z "$dotfiles_url" ]
        then
            _failure "In box.dhall, 'dotfilesUrl' is empty.\nBootstrap can't be realized. Abort user configuration."
            exit 1
        else
            if _clone_dotfiles "$dotfiles_url" $HOME
            then
                _success "clone mr ${dotfiles_url}\n"
            else
                printf '\n'
                _failure "Bootstrap has failed ! Unable to clone ${dotfiles_url}.\nAborting mr configuration."
                return 1
            fi
        fi
    fi
    # mrconfig
    eval $(dhall-to-bash --declare specs <<< "($config_file).mr.config")
    for spec in "${specs[@]}"; do
        if eval mr config "$spec"
        then
            printf 'mr config %s\n' "${spec}"
        else
            _failure "mr configuration has failed for ${spec}"
            exit 1
        fi
    done

    eval $(dhall-to-bash --declare repos <<< "($config_file).mr.repos")
    local mrconfigd="$HOME/.config/mr/config.d"
    if [ -d $mrconfigd ]; then
        find "$mrconfigd" -type l -name "*.mr" -exec rm {} \;
        for repo in "${repos[@]}"; do
            ln -sf "../available.d/${repo}" "${mrconfigd}/${repo}"
        done
    else
        printf 'No ${mrconfigd] directory. No predefined mr repo will be activated.\n'
    fi

    if $bootstrap
    then
        mr -f -d "$HOME" up -q
        _success "mr"
        if nix-shell '<home-manager>' -A install
        then
            _success "home-manager installed.\n"
        else
            printf '\n'
            _failure "Unable to install the home-manager."
            return 1
        fi
    else
        mr -d "$HOME" up -q
        _success "mr"
	printf 'Running the Home-manager ...\n'
        if home-manager switch >/dev/null 2>&1
        then
            _success "home-manager switch"
        else
            _failure "home-manager switch"
        fi
    fi
    set -e
}

install_doc () {
    printf 'Installing doc.\n'
    set +e
    if make doc outdir="$HOME/.local/share/devbox">/dev/null 2>&1
    then
        _success "documentation."
    else
        _failure "documentation not installed successfully."
    fi
    set -e
}

# Install eclipse plugin that are not part of nixpkgs or home-manager
install_extra_eclipse_plugin () {
    full_name="$1"
    repository="$2"
    installUI="$3"
    printf "About to download Eclipse plugin %s. Hold on.\\n" "$full_name"

   eclipse -application "org.eclipse.equinox.p2.director" \
           -repository "${repository}" \
           -installIU "${installUI}" \
           -profile "SDKProfile" \
           -profileProperties "org.eclipse.update.install.features=true" \
           -p2.os "linux" \
           -p2.arch "x86" \
           -roaming -nosplash \
           >/dev/null 2>&1
   if [ $? -eq 0 ]
   then
       printf 'Eclipse plugin %s has been successfully downloaded\n' "$full_name"
   else
       printf 'Failed to download Eclipse plugin %s \n' "$full_name"
   fi
}


# Main

install_ssh_keys
install_mr_repos
install_doc

eval $(dhall-to-bash --declare eclipse <<< "($config_file).eclipse")
if "$eclipse"
then
    eclipse_version_name="2018-12"
    install_extra_eclipse_plugin "org.eclipse.egit" "http://download.eclipse.org/releases/${eclipse_version_name}/" "org.eclipse.egit.feature.group"
    install_extra_eclipse_plugin "org.eclipse.m2e" "http://download.eclipse.org/releases/${eclipse_version_name}/" "org.eclipse.m2e.feature.feature.group"
fi

} | tee "${mount_dir}/user_lastrun.log"
