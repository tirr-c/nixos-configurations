{
  lib,
  buildNpmPackage,
  nodejs,
  writeShellScriptBin,

  appSrc,
  npmDepsHash,
  ...
}:

let
  pname = "frostracker";

  app = buildNpmPackage {
    inherit pname;
    version = "0-unstable";

    src = appSrc;
    inherit npmDepsHash;

    buildPhase = ''
      npm run build
    '';

    installPhase = ''
      mkdir -p $out
      cp -r dist server node_modules package.json $out/
    '';
  };
in

writeShellScriptBin pname ''
  set -eu
  export NODE_ENV=production
  exec ${lib.getExe nodejs} ${app}/server/index.js
''
