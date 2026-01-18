{
  fetchurl,
  stdenvNoCC,
  lib,
  ...
}:

let
  srcs = import ./srcs.nix;
  inherit (srcs) version sources;
in

stdenvNoCC.mkDerivation {
  pname = "nocodb-unwrapped";
  inherit version;

  src =
    let
      base = sources.${stdenvNoCC.hostPlatform.system};
      spec = base // {
        name = "nocodb";
        executable = true;
      };
    in
    fetchurl spec;

  dontUnpack = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    install -m755 -D $src $out/bin/nocodb
    runHook postInstall
  '';

  meta = with lib; {
    platforms = attrsets.attrNames sources;
  };
}
