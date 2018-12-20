# Local customization that won't be overridden by vagrant provision
# To activate your changes, type 'nixreb' in a terminal after saving your file.
{ config, lib, pkgs, ... }:

{

  # Only one desktop should be uncommented.
  # Feel free to try another one.
  imports = [
    # ./puppetdb-dns.nix
    ./desktop-tiling-configuration.nix
    # ./desktop-gnome-configuration.nix
    # ./desktop-kde-configuration.nix
  ];

  nix = {
    binaryCaches = [
      "https://cache.nixos.org/"
      "https://cicd-shell.cachix.org"
      "https://language-puppet.cachix.org"
      "https://puppet-unit-test.cachix.org"
      "https://taffybar.cachix.org"
    ];
    binaryCachePublicKeys = [
      "cicd-shell.cachix.org-1:ajBUZoJNroJ5ldybYoXgXyl2YWuPJ4NJ8Qx3/ksxVEw="
      "language-puppet.cachix.org-1:nyTkkiphUF+s5HO4aDqGXBHD7rGiqz6ygvGYnJQ2feA="
      "puppet-unit-test.cachix.org-1:DcfU2u/QnYWzfTFpjIPEQi1/Nq//yd1lhgORL5+Uf84="
      "taffybar.cachix.org-1:beZotJ1nVEsAnJxa3lWn0zwzZM7oeXmGh4ADRpHeeIo="
    ];
  };

  environment.extraInit = ''
    export _JAVA_AWT_WM_NONREPARENTING=1 # Fix intelliJ blank popup
    export DESKTOP_SESSION=gnome
    export BROWSER=google-chrome-stable
  '';
  environment.systemPackages = with pkgs; [
    # ansible
    # asciidoctor
    # atom
    bind
    # bundix
    # cabal2nix
    # dnsmasq
    docker
    # docker_compose
    # filebeat
    # firefox
    # geany
    # gitAndTools.tig
    gnome3.nautilus
    # go2nix
    google-chrome
    gnupg
    # gnome3.file-roller
    htop
    # jetbrains.idea-community
    # jetbrains.idea-ultimate
    # haskellPackages.shake
    jdk
    # maven
    # nix-prefetch-git
    # nodejs
    # nodePackages.tern
    # openssl
    # pandoc
    paper-gtk-theme
    paper-icon-theme
    parallel
    # parcellite
    python
    # taskwarrior
    # terraform
    # ruby
    # rxvt_unicode-with-plugins
    silver-searcher
    shellcheck
    # sublime3
    tree
    # tmux
    unzip
    vscode
    # zeal
    zip
    zsh
    zsh-completions
  ];

  # zsh config
  programs.zsh = {
    enable = true;
    ohMyZsh.enable = true;
    ohMyZsh.custom = "$HOME/.zsh_custom";
    ohMyZsh.theme = "lambda-mod";
    ohMyZsh.plugins = [ "cicd" "autosuggestion"];
    interactiveShellInit = ''
      setopt globdots
      nlink () {
          readlink -f $(which "$1")
      }
    '';
    shellAliases = {
      la = " ls -alh";
      ls = " ls --color=tty";
      ll = "ls -lh";
      duh = " du -h --max-depth=1";
      df = " df -h";
      ag = "ag --color-line-number=3";
      vi = "vim";
      chrome = "google-chrome-stable";
      see = "./bin/check_role.sh";
      heyaml = "./bin/eyaml.sh $@";
      fixlint = "./bin/fix-lint.sh";
      nixreb = "sudo nixos-rebuild switch";
      ldir = "ls -ladh (.*|*)(/,@)";
      lfile = "ls -lah *(.)";
    };
  };
  users.defaultUserShell = "/run/current-system/sw/bin/zsh";

  # Launch virtualbox from its UI and get the /vagrant shared folder
  fileSystems."/vagrant" = {
    fsType = "vboxsf";
    device = "vagrant";
    options = [ "rw" ];
  };

  virtualisation.docker.enable = true;
  # Enable the puppetdb dns service
  # services.puppetdb-dns.enable = true;

  # Postgresql server
  # services.postgresql = {
  #   enable = true;
  # #  authentication = ''
  # #    local saltstack salt trust
  # #  '';
  # #   initialScript = /vagrant/initdb.sql;
  # };

  # Salt server
  # networking.extraHosts = ''
  #   127.0.0.1 salt
  # '';
  # services.salt.master = {
  #   enable = true;
  # };
  # services.salt.minion.enable = true;

  # Elasticsearch with Kibana
  # services.rsyslogd.enable = true;
  # services.elasticsearch = {
  #   enable = true;
  #   package = pkgs.elasticsearch6;
  # };
  # services.kibana = {
  #   enable = true;
  #   package = pkgs.kibana6;
  # };

  # Kubernetes labs
  # services.kubernetes = {
  #   roles = ["master" "node"];
  #   addons.dashboard.enable = true;
  # };

}
