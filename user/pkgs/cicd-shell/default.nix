{ mkDerivation, base, lens, optional-args, process, raw-strings-qq
, stdenv, fetchgit, text, turtle, jq, pepper
}:
mkDerivation {
  pname = "cicd-shell";
  version = "0.9.10";
  src = fetchgit {
    url = "http://stash.cirb.lan/scm/cicd/cicd-shell.git";
    rev = "452e710591a52c0db350f8c50019a4edddab2a35";
    sha256= "0hamwqirwi2xmh86xhknib4db6f64sqljr6xqghpnzzrc1nxy044";
  };
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    base lens optional-args process raw-strings-qq text turtle
  ];
  executableSystemDepends = [ jq pepper ];
  homepage = "ssh://git@stash.cirb.lan:7999/cicd/salt-shell.git";
  license = stdenv.lib.licenses.bsd3;
}
