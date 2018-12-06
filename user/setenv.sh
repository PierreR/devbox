#! /usr/bin/env nix-shell
#! nix-shell -i bash -p vcsh dhall-bash
set -eu

if [ -t 0 ]
then
    NORMAL=$(tput sgr0)
fi

# Utils
_append () {
    grep -qF -- "$1" "$2" || ( echo "Appending ${1} in ${2}"; echo "$1" >> "$2" )
}
_success () {
    if [ -t 0 ]
    then
        local GREEN=$(tput setaf 2)
        echo -e "${GREEN}Done with $1 ${NORMAL}\n"
    else
        printf "Done with $1 \n"
    fi
}
_failure () {
    if [ -t 0 ]
    then
        local RED=$(tput setaf 1)
        echo -e "${RED}FAILURE: $1 ${NORMAL}\n"
    else
        printf "FAILURE: $1 \n"
    fi
}

config_file=$1

if [ ! -f "$config_file" ]; then
    _failure "please pass a valid configuration as first argument. Can't find ${config_file}."
    exit 1
fi


install_ssh_keys () {
    printf 'Synchronizing ssh keys\n'
    local ssh_hostdir="/vagrant/ssh-keys"
    local guestdir="$HOME/.ssh/"
    if [ -d "$ssh_hostdir" ]; then
        cp user/ssh-config "${guestdir}/config"
        # rsync -i --chmod=644 ${ssh_hostdir}/*.pub "$guestdir"
        find "$ssh_hostdir" -type f -name "*.*" -exec rsync -ai --chmod=644 {} "$guestdir" \;
        find "$ssh_hostdir" -type f ! -name "*.*" -exec rsync -ai --chmod=600 {} "$guestdir" \;
        _success "install ssh keys"
    else
        _failure "no ssh-keys directory found. You won't be able to push anything to stash.cirb.lan."
    fi
}

configure_git () {
    printf 'Configurating git\n'
    eval $(dhall-to-bash --declare user_name <<< "($config_file).userName")
    eval $(dhall-to-bash --declare user_email <<< "($config_file).userEmail")
    if [ -n "${user_name}" ]; then git config --global user.name "${user_name}"; fi
    if [ -n "${user_email}" ]; then git config --global user.email "${user_email}"; fi
}

configure_wallpaper () {
    printf 'Configuring wallpaper\n'
    eval $(dhall-to-bash --declare filename <<< "($config_file).wallpaper")
    ln -sf "${HOME}/.wallpaper/${filename}" "$HOME/.wallpaper.jpg"
}

configure_console () {
    printf 'Configuring console\n'
    local filepath="$HOME/.config/termite"
    eval $(dhall-to-bash --declare color <<< "($config_file).console.color")
    if [ -f "${filepath}/${color}" ]; then
        ln -sf "${filepath}/${color}" "${filepath}/config"
    fi
}

set_login_id () {
    printf 'Configuring the LOGINID environment variable.\n'
    eval $(dhall-to-bash --declare login_id <<< "($config_file).loginId")
    if [ -n "$login_id" ]
    then
        _append "export LOGINID='$login_id'" "$HOME/.zshenv"
    else
        printf '\nCommandline tool that requires AD authentication (such as the cicd-shell) expects a LOGINID environment variable.\n'
        _failure "cannot set your AD loginId. Is it empty in the box.dhall configuration ?"
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
            if vcsh clone "$template_url" mr
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
    if [ -d "$mrconfigd" ]; then
        find $mrconfigd -type l -name "*.mr" -exec rm {} \;
        for repo in "${repos[@]}"; do
            ln -sf "../available.d/${repo}" "${mrconfigd}/${repo}"
        done
    else
        printf 'No ${mrconfigd] directory. No predefined mr repo will be activated.\n'
    fi

    if $bootstrap
    then
        mr -f -d "$HOME" up -q
    else
        mr -d "$HOME" up -q
    fi
    set -e
    _success "mr"
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
        mkdir -p filepath
        cp -r doc filepath
        _success "documentation."
    else
        _failure "documentation not installed successfully."
    fi
    set -e
}

# Main
install_ssh_keys
install_env_packages
install_mr_repos
# These needs to be after because they depends on the vcsh bootstrap that fetch the dotfiles.
configure_wallpaper
configure_console
configure_git
set_login_id
install_doc

eval $(dhall-to-bash --declare eclipse <<< "($config_file).eclipse")
if "$eclipse"
then
    ./user/eclipse.sh
fi
