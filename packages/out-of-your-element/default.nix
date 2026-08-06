{
  lib,
  buildNpmPackage,
  fetchFromForgejo,
  nodejs,
  writeShellScriptBin,
  ...
}:

let
  pname = "out-of-your-element";

  rev = "85b9e4743f1718399bdc18eb882ccc1c92ff0689";
  hash = "sha256-D2yTHmol6n38XMsHKeZKEw+7gEszOf9P3C53lOM8Tcs=";
  npmDepsHash = "sha256-uWbIVwK4kETkEL17QPy5t7LfpIItSgPCZkatOgJ4Ub0=";

  ooye = buildNpmPackage (finalAttrs: {
    inherit pname;
    version = "0-unstable-${rev}";

    src = fetchFromForgejo {
      domain = "gitdab.com";
      owner = "cadence";
      repo = "out-of-your-element";
      inherit rev hash;
    };

    dontNpmBuild = true;

    inherit npmDepsHash;

    inherit nodejs;
  });
in

writeShellScriptBin pname ''
  set -eu

  case "''${1:-}" in
    start) script=start.js;;
    setup) script=setup.js;;
    addbot) script=addbot.js;;
    "")
      echo "Usage: ''$0 <start|setup|addbot>" >&2
      exit 1
    ;;
    *)
      echo "Unknown subcommand `''$subcmd`" >&2
      echo "Usage: ''$0 <start|setup|addbot>" >&2
      exit 1
    ;;
  esac

  exec ${lib.getExe nodejs} --enable-source-maps \
    ${ooye}/lib/node_modules/out-of-your-element/''$script
''
