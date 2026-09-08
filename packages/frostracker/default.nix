{
  lib,
  buildNpmPackage,
  nodejs,
  writeShellScriptBin,
  ...
}:

let
  pname = "frostracker";
  rev = "14025aadcad97b8d1d29cbb3146eaf11051c0d0c";
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
