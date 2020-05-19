#! /usr/bin/env bash

eclipse_version_name="2019-06"

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

install_extra_eclipse_plugin "org.eclipse.egit" "http://download.eclipse.org/releases/${eclipse_version_name}/" "org.eclipse.egit.feature.group"
install_extra_eclipse_plugin "org.eclipse.m2e" "http://download.eclipse.org/releases/${eclipse_version_name}/" "org.eclipse.m2e.feature.feature.group"
