{
  lib,
  buildNpmPackage,
  nodejs,
  writeShellScriptBin,
  ...
}:

let
  pname = "frostracker";
  rev = "65c1d713feb84e13fb63eff1b7f3138b0b34c444";
  npmDepsHash = "sha256-xLUPn4JPM2MC9N6tY8RvsB9AFTBo12nuK/QsWlU1Xfo=";

  app = buildNpmPackage {
    inherit pname;
    version = "0-unstable-${rev}";

    src = fetchGit {
      url = "ssh+git://git@github.com/ektnzpt1080/frosthaven-tracker.git";
      inherit rev;
    };

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
