{
  fetchurl,
  stdenv,
  stdenvNoCC,
  makeWrapper,
  lib,
  ...
}:

let
  srcs = import ./srcs.nix;
  inherit (srcs) version sources;
in

stdenvNoCC.mkDerivation {
  pname = "nocodb";
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

  nativeBuildInputs = [
    makeWrapper
  ];

  unpackPhase = ''
    runHook preUnpack
    cp $src ./nocodb
    runHook postUnpack
  '';

  dontFixup = true;

  installPhase = ''
    runHook preInstall
    install -m755 -D nocodb $out/bin/nocodb
    wrapProgram $out/bin/nocodb \
      --suffix LD_LIBRARY_PATH : ${lib.makeLibraryPath [stdenv.cc.cc]}
    runHook postInstall
  '';

  meta = with lib; {
    platforms = attrsets.attrNames sources;
  };
}
