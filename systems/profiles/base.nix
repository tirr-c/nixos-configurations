{ inputs, host, lib, pkgs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];

    # Common local builders
    trusted-public-keys = [
      (builtins.readFile ../herta/nix-store-public-key.pub)
      (builtins.readFile ../frieren/nix-store-public-key.pub)
    ];
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://fenix.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "fenix.cachix.org-1:ecJhr+RdYEdcVgUkjruiYhjbBloIEGov7bos90cZi0Q="
    ];
  };

  programs.nh = {
    enable = true;
    flake = "/etc/nixos";

    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep 10 --keep-since 7d";
    };
  };

  boot.loader.systemd-boot.configurationLimit = 10;

  networking.hostName = lib.mkDefault host;

  environment.systemPackages = lib.mkAfter [ pkgs.cachix ];
}
