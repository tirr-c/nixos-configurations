{
  callPackage,
  buildFHSEnv,
  ...
}:

let
  unwrapped = callPackage ./unwrapped.nix {};
in

buildFHSEnv {
  pname = "nocodb";
  version = unwrapped.version;

  targetPkgs = pkgs: [
    pkgs.stdenv.cc.cc
  ];
  runScript = "${unwrapped}/bin/nocodb";
}
