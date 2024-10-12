{
  inputs,
  host,
  lib,
  useLix ? false,
  ...
}:

let
  inherit (inputs) lix-module home-manager;

  lixImports = lib.optionals useLix [
    lix-module.nixosModules.default
    {
      nix.settings = {
        extra-substituters = lib.mkAfter [
          "https://cache.lix.systems"
        ];
        extra-trusted-public-keys = lib.mkAfter [
          "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
        ];
      };
    }
  ];
in
{
  imports = [
    home-manager.nixosModules.home-manager
  ] ++ lixImports;

  nix.settings.experimental-features = lib.mkBefore [ "nix-command" "flakes" ];
  networking.hostName = lib.mkDefault host;
}
