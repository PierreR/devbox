{ mkDerivation, ansi-wl-pprint, base, dhall, foldl, lens, mtl
, neat-interpolation, protolude, stdenv, text, turtle, vector
}:
mkDerivation {
  pname = "devbox-user";
  version = "0.1.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    ansi-wl-pprint base dhall foldl lens mtl neat-interpolation
    protolude text turtle vector
  ];
  license = stdenv.lib.licenses.bsd3;
}
