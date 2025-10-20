{ inputs, host, lib, pkgs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  nix.settings = {
    experimental-features = lib.mkBefore [ "nix-command" "flakes" ];

    extra-substituters = lib.mkAfter [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = lib.mkAfter [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
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
