#! /usr/bin/env nix-shell
#! nix-shell -i bash -p vcsh dhall-bash

script_dir="$(dirname -- "$(readlink -f -- "$0")")"

mount_dir=$1
if [ ! -d "$mount_dir" ]; then
    _failure "${mount_dir} is not a directory. Please pass a valid ROOT_DIR"
    exit 1
fi

config_file="${mount_dir}/box.dhall"
if [ ! -f "$config_file" ]; then
    echo "Add empty configuration in ${config_file}. Please fill in ${config_file} with your personal data."
    cp --verbose config/box-cirb.dhall "$config_file"
fi

local_config="${mount_dir}/local-home.nix"
if [ !  -f "$local_config" ]; then
    echo "Add ${local_config}. You might want to customize this user configuration file later."
    cp --verbose "${script_dir}/local-home.nix" "$local_config"
fi

{

source utils.sh

set -eu

# We need to keep this out of the home-manager to succeed the bootstrap phase.
# Bootrapping is currently handled with vcsh and a dotfiles repository pulled from ssh.
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


install_mr_repos () {
    set +e
    printf 'Installing mr repos\n'
    declare bootstrap=false
    if [ ! -f "$HOME/.mrconfig" ]; then
        bootstrap=true
        # bootstrap: vcsh clone of the mr remplate url
        eval $(dhall-to-bash --declare template_url <<< "($config_file).mr.templateUrl")
        if [ -z "$template_url" ]
        then
            printf 'mr.templateUrl is empty. You won\"t not be able to activate pre-defined mr repositories.\n'
        else
            if git clone --separate-git-dir=$HOME/.config/dotfiles "$template_url" dotfiles
            then
                _success "clone mr ${template_url}\n"
            else
                printf '\n'
                _failure "vcsh bootstrap has failed ! Unable to clone ${template_url}.\nAborting mr configuration."
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
        if home-manager switch >/dev/null 2>&1
        then
            _success "home-manager switch"
        else
            _failure "home-manager switch"
        fi
    fi
    set -e
}

install_env_packages () {
    printf 'Installing user packages (nix-env).\n'
    set +e
    eval $(dhall-to-bash --declare specs <<< "($config_file).nix-env")
    for spec in "${specs[@]}"
    do
        if nix-env -Q --quiet --install $spec
        then
            printf 'nix-env --install %s\n' "${spec}"
        else
            _failure "enable to install ${spec}"
        fi
    done
    _success "nix-env"
    set -e
}

install_doc () {
    printf 'Installing doc.\n'
    set +e
    if make doc >/dev/null 2>&1
    then
        local filepath="$HOME/.local/share"
        mkdir -p "$filepath"
        cp -r doc "$filepath"
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
install_env_packages
install_mr_repos
# These needs to be after because they depends on the vcsh bootstrap that fetch the dotfiles.
install_doc

eval $(dhall-to-bash --declare eclipse <<< "($config_file).eclipse")
if "$eclipse"
then
    eclipse_version_name="2018-12"
    install_extra_eclipse_plugin "org.eclipse.egit" "http://download.eclipse.org/releases/${eclipse_version_name}/" "org.eclipse.egit.feature.group"
    install_extra_eclipse_plugin "org.eclipse.m2e" "http://download.eclipse.org/releases/${eclipse_version_name}/" "org.eclipse.m2e.feature.feature.group"
fi

} | tee "${mount_dir}/user_lastrun.log"
