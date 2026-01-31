{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
  deno,
  writeShellScriptBin,
  ...
}:

let
  pname = "nocodb-webhooks";

  src = fetchFromGitHub {
    owner = "tirr-c";
    repo = "nocodb-webhooks";
    rev = "c8f0fbee74706106c3e10cf1d2c97b1ce86c71ba";
    hash = "sha256-9CwmJ40A9ZB+GsEjt4NvOoutZ4+uBPxIf7UhnwBsfGg=";
  };

  depsHash = "sha256-GQZhVDBMONmpsicGwRZqbwvMic3LBvRcaAqSvBAIW+4=";
  denoDeps = stdenvNoCC.mkDerivation {
    name = "${pname}-deps";
    inherit src;

    nativeBuildInputs = [
      deno
    ];

    phases = "unpackPhase patchPhase buildPhase installPhase";

    buildPhase = ''
      DENO_DIR=.deno deno install --lock deno.lock --frozen
      rm .deno/*cache*
    '';

    installPhase = ''
      mkdir -p $out
      cp -r -t $out/ .deno/*
    '';

    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = if depsHash == "" then lib.fakeHash else depsHash;
  };

  app = stdenvNoCC.mkDerivation {
    name = "${pname}-app";

    srcs = [
      src
      denoDeps
    ];

    sourceRoot = ".";

    nativeBuildInputs = [
      deno
    ];

    buildPhase = ''
      runHook preBuild

      pushd ${src.name}/
      DENO_DIR=../${denoDeps.name} deno info
      DENO_DIR=../${denoDeps.name} deno install \
        --lock deno.lock --frozen --cached-only \
        --entrypoint main.ts
      popd

      rm ${denoDeps.name}/*cache*

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r ${denoDeps.name} $out/cache
      cp -r ${src.name} $out/app

      runHook postInstall
    '';

    dontStrip = true;
  };
in

writeShellScriptBin pname ''
  export DENO_DIR=${app}/cache
  exec ${lib.getExe deno} run \
    --lock ${app}/app/deno.lock --frozen --cached-only \
    --allow-env --allow-net \
    ${app}/app/main.ts
''
