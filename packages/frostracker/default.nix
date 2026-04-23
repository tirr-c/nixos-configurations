{
  lib,
  buildNpmPackage,
  nodejs,
  writeShellScriptBin,
  ...
}:

let
  pname = "frostracker";
  rev = "52606ea998baacafe6a0bcdfa390da9f09abd3dc";
  npmDepsHash = "sha256-xLUPn4JPM2MC9N6tY8RvsB9AFTBo12nuK/QsWlU1Xfo=";

  app = buildNpmPackage {
    inherit pname;
    version = "0-unstable-${rev}";

    src = builtins.fetchGit {
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
