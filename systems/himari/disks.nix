{ ... }:

{
  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
    options = ["noatime"];
  };

  boot.zfs.forceImportRoot = false;

  swapDevices = [];
}
