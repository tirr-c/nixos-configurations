{
  lib,
  buildNpmPackage,
  fetchFromForgejo,
  nodejs_22,
  writeShellScriptBin,
  ...
}:

let
  nodejs = nodejs_22;

  pname = "out-of-your-element";

  rev = "c7389ff2d6feb1c33a7f5963984c468691dc1b72";
  hash = "sha256-Jrt0jQzKgJJaZ5btk7okw2+65KZx27P8n4/xvykns3Y=";
  npmDepsHash = "sha256-4iJCCpw+0YEnMPBAlHx6cOSImEjjOm/fbwzPnwzQrxw=";

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
