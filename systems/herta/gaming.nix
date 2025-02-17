{ pkgs, inputs, ... }:

{
  imports = [
    inputs.aagl.nixosModules.default
  ];

  nix.settings = {
    substituters = ["https://ezkea.cachix.org"];
    trusted-public-keys = ["ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="];
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    protontricks.enable = true;
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
