{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    discord-canary
  ];

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
      fcitx5-hangul
    ];
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = import ./default-fonts.nix;
  };
}
