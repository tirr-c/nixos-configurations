{ config, pkgs, ... }:

{
  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.limine = {
    enable = true;
    efiSupport = true;
    biosSupport = false;

    maxGenerations = 5;
    resolution = "3840x2160x32";

    additionalFiles = {
      "efi/memtest86/memtest86.efi" = "${pkgs.memtest86-efi}/BOOTX64.efi";
    };
    extraEntries = ''
/memtest86
  protocol: chainload
  path: boot():///efi/memtest86/memtest86.efi
'';
  };

  environment.systemPackages = [
    config.boot.loader.limine.secureBoot.sbctl
  ];
}
