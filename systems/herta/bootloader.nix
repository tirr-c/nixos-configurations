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

    extraEntries = ''
/Windows
  protocol: efi
  path: uuid(b4411b06-2a9e-49fb-9db5-d56836185676):/EFI/Microsoft/Boot/bootmgfw.efi
'';
  };

  boot.loader.timeout = lib.mkForce 10;

  environment.systemPackages = [
    sbctl
  ];
}
