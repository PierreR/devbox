#! /usr/bin/env bash
set -eu

NORMAL=$(tput sgr0)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)

# Utils
_append () {
    grep -qF -- "$1" "$2" || ( echo "Appending ${1} in ${2}"; echo "$1" >> "$2" )
}
_success () {
    echo -e "${GREEN}Done with $1 ${NORMAL}\n"
}
_failure () {
    echo -e "${RED}FAILURE: $1 ${NORMAL}\n"
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
    ln -sf "${HOME}/.wallpaper/${filename}" "$HOME/.wallaper.jpg"
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
    eval $(dhall-to-bash --declare login_id <<< "($config_file).loginId")
    _append "export LOGINID='$login_id'" "$HOME/.zshenv"
}

install_mr_repos () {
    set +e
    printf 'Installing mr repos\n'
    declare bootstrap=false
    if [ -f "$HOME/.mrconfig" ]; then
        bootstrap=true
        # bootstrap: vcsh clone of the mr remplate url
        eval $(dhall-to-bash --declare template_url <<< "($config_file).mr.templateUrl")
        if [ ! -z "$template_url" ]
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
    find $mrconfigd -type l -name "*.mr" -exec rm {} \;
    for repo in "${repos[@]}"; do
        ln -sf "../available.d/${repo}" "${mrconfigd}/${repo}"
    done
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
configure_git
configure_wallpaper
configure_console
set_login_id
install_ssh_keys
install_mr_repos
install_env_packages
install_doc

eval $(dhall-to-bash --declare eclipse <<< "($config_file).eclipse")
if "$eclipse"
then
    ./user/eclipse.sh
fi
