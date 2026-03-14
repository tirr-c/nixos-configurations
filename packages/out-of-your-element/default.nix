{
  lib,
  buildNpmPackage,
  fetchgit,
  nodejs,
  writeShellScriptBin,
  ...
}:

let
  pname = "out-of-your-element";

  rev = "e6c3013993e8e365549b1db9a249ed5b544b1e9a";
  hash = "sha256-SQYErgPvoLCcwdUwCa2bPn/3tC0Z5OkhpyzmjrVB0no=";
  npmDepsHash = "sha256-rh0JKZ1ldQTy9V2QTCluDTDG7PsZOKRD9eEXPYv8peI=";

  ooye = buildNpmPackage (finalAttrs: {
    inherit pname;
    version = "0-unstable-${rev}";

    src = fetchgit {
      url = "https://gitdab.com/cadence/out-of-your-element.git";
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
