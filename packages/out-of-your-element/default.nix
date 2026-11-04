{
  lib,
  buildNpmPackage,
  fetchFromForgejo,
  nodejs,
  writeShellScriptBin,
  ...
}:

let
  ooye = buildNpmPackage (finalAttrs: {
    pname = "out-of-your-element";
    version = "3.8.2";

    src = fetchFromForgejo {
      domain = "gitdab.com";
      owner = "cadence";
      repo = "out-of-your-element";
      rev = "v${finalAttrs.version}";
      hash = "sha256-o5T/feGrwKTB0BJ5HZbaw/q2e+/uzSzBBHJHpgrGKnI=";
    };

    npmDepsHash = "sha256-a/4bZ1tKpI28ndOqdzsB+PsrPpnJTlBygOkMjNSmPY4=";
    dontNpmBuild = true;

    inherit nodejs;
  });
in

writeShellScriptBin "out-of-your-element" ''
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
