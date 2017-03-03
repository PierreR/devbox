
{
    allowBroken = true;
    allowUnfree = true;

    packageOverrides = super:
      with super.haskell.lib;

      let self = super.pkgs;
          hghc = self.haskellPackages;
          hiera-eyaml-gpg = self.bundlerEnv rec {
            name = "hiera-eyaml-gpg-${version}";
            version = "0.6";

            gemfile = ./pkgs/hiera-eyaml-gpg/Gemfile;
            lockfile = ./pkgs/hiera-eyaml-gpg/Gemfile.lock;
            gemset = ./pkgs/hiera-eyaml-gpg/gemset.nix;

          };
          pepper = self.pythonPackages.buildPythonPackage rec {
            name = "salt-pepper-${version}";
            version = "0.4.1";
            src = self.fetchurl {
                url = "https://github.com/saltstack/pepper/releases/download/${version}/${name}.tar.gz";
                sha256 = "1a9b78afa5f68443e18569532d8216d0bf3b1364006b81f9472e4fa7a3dfcf17";
            };
          };

          puppet-env = self.bundlerEnv rec {
            name = "puppet-env-${version}";
            version = "4.7.0";

            gemfile = ./pkgs/puppet-env/Gemfile;
            lockfile = ./pkgs/puppet-env/Gemfile.lock;
            gemset = ./pkgs/puppet-env/gemset.nix;
          };

          dhall_git = hghc.callCabal2nix "dhall_git" (self.fetchFromGitHub {
            owner  = "Gabriel439";
            repo   = "Haskell-Dhall-Library";
            rev    = "505a786c6dd7dcc37e43f3cc96031d30028625be";
            sha256 = "1dsjy4czxcwh4gy7yjffzfrbb6bmnxbixf1sy8aqrbkavgmh8s29";
          }) {};

          cicd-shell = dontCheck (dontHaddock(self.haskellPackages.callPackage ./pkgs/cicd-shell/. {
            dhall = dhall_git;
          }));
      in
      {
        inherit hiera-eyaml-gpg pepper puppet-env cicd-shell;
      };
}
