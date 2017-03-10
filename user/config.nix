
{
    allowBroken = true;
    allowUnfree = true;

    packageOverrides = super:

      let self = super.pkgs;
          hghc = self.haskellPackages;
          hlib = self.haskell.lib;
          hiera-eyaml-gpg = self.bundlerEnv rec {
            name = "hiera-eyaml-gpg-${version}";
            version = "0.6";

            gemfile = ./pkgs/hiera-eyaml-gpg/Gemfile;
            lockfile = ./pkgs/hiera-eyaml-gpg/Gemfile.lock;
            gemset = ./pkgs/hiera-eyaml-gpg/gemset.nix;

          };
          puppet-env = self.bundlerEnv rec {
            name = "puppet-env-${version}";
            version = "4.7.0";

            gemfile = ./pkgs/puppet-env/Gemfile;
            lockfile = ./pkgs/puppet-env/Gemfile.lock;
            gemset = ./pkgs/puppet-env/gemset.nix;
          };
      in
      {
        inherit hiera-eyaml-gpg puppet-env;
      };
}
