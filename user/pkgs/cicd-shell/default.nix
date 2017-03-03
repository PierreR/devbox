{ mkDerivation, base, lens, optional-args, process, raw-strings-qq
, stdenv, fetchgit, text, turtle, jq, pepper, dhall
}:
mkDerivation {
  pname = "cicd-shell";
  version = "1.0.2";
  src = fetchgit {
    url = "http://stash.cirb.lan/scm/cicd/cicd-shell.git";
    rev = "a75d119dc437c12a3481aa01149fb227352589ee";
    sha256 = "00z82fzrg95pwq5fh1p05yc35fab5vp6sm73gncyj4l57vj4zk6h";
  };
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    base dhall lens optional-args process raw-strings-qq text turtle
  ];
  executableSystemDepends = [ jq pepper ];
  homepage = "ssh://git@stash.cirb.lan:7999/cicd/salt-shell.git";
  license = stdenv.lib.licenses.bsd3;
}
