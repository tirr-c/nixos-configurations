{ pkgs, inputs, lib, ... }:

{
  imports = [
    inputs.aagl.nixosModules.default
  ];

  nixpkgs.overlays = with inputs.self.overlays; [
    mbedtls
  ];

  nix.settings = {
    extra-substituters = lib.mkAfter [
      "https://ezkea.cachix.org"
    ];
    extra-trusted-public-keys = lib.mkAfter [
      "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
    ];
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    protontricks.enable = true;
    gamescopeSession.enable = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  programs.honkers-railway-launcher.enable = true;

  environment.systemPackages = with pkgs; [
    gamemode
    lutris
    steamtinkerlaunch
  ];
}
