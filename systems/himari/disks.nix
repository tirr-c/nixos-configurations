{ config, ... }:

{
  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
    options = ["noatime"];
  };

  fileSystems.${config.hardware.raspberry-pi.firmware.path} = {
    device = "/dev/disk/by-label/FIRMWARE";
    fsType = "vfat";
    options = ["noatime"];
  };

  boot.zfs.forceImportRoot = false;

  swapDevices = [];
}
