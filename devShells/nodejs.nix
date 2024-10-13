{
  pkgs,
  nodejs ? pkgs.nodejs-slim,
  corepack,
  ...
}:

pkgs.mkShell {
  name = "nodejs-${nodejs.version}";
  packages = [
    nodejs
    corepack
  ];
}
