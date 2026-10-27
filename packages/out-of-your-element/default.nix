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

  rev = "d2ea49cefd0b60bbdddff715ad4f8744d13df7a7";
  hash = "sha256-4tPZE/Ij8xUkP9yFQ7LDbklSRWu1aEHOurnkXLt/k90=";
  npmDepsHash = "sha256-cte2ouQeLxfQLtzXZT49VHxr30HXG91lV/xjsN3Whn4=";

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
