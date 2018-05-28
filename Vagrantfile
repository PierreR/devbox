# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  scm_uri = "https://github.com/CIRB/devbox"
  scm_api = "https://api.github.com/repos/CIRB/devbox/releases"

  config.vm.box = "devbox-3.7.1-pre"

  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
    vb.memory = "4832"
    vb.cpus = "3"
    vb.customize ["modifyvm", :id, "--vram", "64"]
    vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
    vb.customize ["modifyvm", :id, "--accelerate3d", "off"]
    vb.customize ["modifyvm", :id, "--vrde", "off"]
    vb.customize ["modifyvm", :id, "--audio", "none"]
  end

  config.vm.provision "system", args: [scm_uri, scm_api], type: "shell", name: "configure-system", inline: <<-SHELL
    ping -c1 8.8.8.8 > /dev/null
    if [[ $? -ne 0 ]]; then
      echo "No internet connexion. Exit";
      exit 1;
    fi
    scm_uri=$1
    scm_api=$2
    version="#{ENV['DEVBOX_WITH_VERSION']}"
    if [[ -z "${version}" ]]; then
      version="$(curl -s ${scm_api}/latest | jq -r .tag_name)"
    else
      echo "Overriding latest version with ${version}";
    fi
    configdir="devbox-${version}"
    mkdir -p /tmp/system
    pushd /tmp/system > /dev/null;
    if [[ ! -d "${configdir}" ]]; then
      echo "Fetching ${version} configuration from ${scm_uri}";
      curl -s -L ${scm_uri}/archive/${version}.tar.gz | tar xz;
      pushd ${configdir} > /dev/null;
      make system
      popd > /dev/null;
    fi
    popd > /dev/null;
  SHELL

  config.vm.provision "user", args: [scm_uri, scm_api], type: "shell" , name: "configure-user", privileged: false, inline: <<-SHELL
    ping -c1 8.8.8.8 > /dev/null
    if [[ $? -ne 0 ]]; then
      echo "No internet connexion. Exit";
      exit 1;
    fi
    scm_uri=$1
    scm_api=$2
    version="#{ENV['DEVBOX_WITH_VERSION']}"
    if [[ -z "${version}" ]]; then
      version="$(curl -s ${scm_api}/latest | jq -r .tag_name)"
    else
      echo "Overriding latest version";
    fi
    configdir="devbox-${version}"
    [[ -d "/tmp/user" ]] || mkdir /tmp/user
    pushd /tmp/user > /dev/null;
    if [[ ! -d "${configdir}" ]]; then
      echo "Cloning ${version} configuration from ${scm_uri}";
      git clone --depth 1 --branch ${version} ${scm_uri} ${configdir} > /dev/null 2>&1;
      pushd ${configdir} > /dev/null;
      git submodule update --init;
      make user;
      popd > /dev/null;
    else
      pushd ${configdir} > /dev/null; make sync-user; popd > /dev/null;
    fi
    popd > /dev/null;
  SHELL

end
