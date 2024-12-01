{
  inputs,
  host,
  lib,
  pkgs,
  useLix ? false,
  ...
}:

let
  inherit (inputs) lix-module home-manager;

  lixImports = lib.optionals useLix [
    lix-module.nixosModules.lixFromNixpkgs
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

  cachix = {
    extra-substituters = lib.mkAfter [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = lib.mkAfter [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
in
{
  imports = [
    home-manager.nixosModules.home-manager
  ] ++ lixImports;

  nix.settings = {
    experimental-features = lib.mkBefore [ "nix-command" "flakes" ];
  } // cachix;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  boot.loader.systemd-boot.configurationLimit = 10;

  networking.hostName = lib.mkDefault host;

  environment.systemPackages = lib.mkAfter [ pkgs.cachix ];
}
