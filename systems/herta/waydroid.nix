{ pkgs, ... }:

{
  virtualisation.waydroid.enable = true;

  environment.defaultPackages = with pkgs; [
    nur.repos.ataraxiasjel.waydroid-script
  ];
}
