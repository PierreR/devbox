#! /usr/bin/env bash
set -u

version_name="2018-12"
plugins="jdt yedit testng"
pin="https://github.com/NixOS/nixpkgs/archive/5c52b25283a6cccca443ffb7a358de6fe14b4a81.tar.gz"

install_eclipse () {
    printf "About to install Eclipse %s. Hold on.\n" "$version_name"
    nix-env -Q --quiet -i \
            -f "${pin}" \
            -E "pkgs: with pkgs {}; eclipses.eclipseWithPlugins { eclipse = eclipses.eclipse-sdk; jvmArgs = [ \"-javaagent:\${lombok.out}/share/java/lombok.jar\" ];plugins = with eclipses.plugins; [ ${plugins} ];}"
    if [ $? -eq 0 ]
    then
        extra_plugin "org.eclipse.egit" "http://download.eclipse.org/releases/${version_name}/" "org.eclipse.egit.feature.group"
        extra_plugin "org.eclipse.m2e" "http://download.eclipse.org/releases/${version_name}/" "org.eclipse.m2e.feature.feature.group"
    fi
}

extra_plugin () {
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

install_eclipse
