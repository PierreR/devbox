# common functions in user spaces
# personal definition should be written in SHARED_DIR/local.nix
function sshi () {
    if [ -z "$1" ]
    then
        echo "Please specify the machine fqdn or IP";
    else
	      TERM=xterm ssh -A -i ~/.ssh/cirb_rsa $LOGINID@$1
    fi
}

function sshp () {
    if [ -z "$1" ]
    then
	echo "Please specify the target (username@machine)";
    else
	TERM=xterm ssh -o PreferredAuthentications=keyboard-interactive,password -o PubkeyAuthentication=no $1
    fi
}
# Update provision from bootstrap
# Before re-make the system
function updateSystem () {
    echo "Provisioning devbox"
    vcsh dotfiles pull --quiet --rebase --ff-only
    sudo make system
}

# Update provision both from dotfiles and bootstrap
# Before re-make the user
function updateUser () {
    echo "Provisioning devbox"
    vcsh dotfiles pull --quiet --rebase --ff-only
    make user
}

# Don't provision anything, just update the user with the current (user) configuration
function updateConfig () {
    pushd ~ > /dev/null
    make user
    popd > /dev/null 2>&1
}
