{ config, lib, ... }:

let
  sbctl = config.boot.loader.limine.secureBoot.sbctl;
in

{
  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.limine = {
    enable = true;
    efiSupport = true;
    biosSupport = false;
    efiInstallAsRemovable = false;

    secureBoot.enable = true;

    maxGenerations = 5;
    resolution = "3840x2160x32";
  };

  boot.loader.timeout = lib.mkForce 1;

  environment.systemPackages = [
    sbctl
  ];
}
