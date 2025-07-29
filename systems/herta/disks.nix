{ ... }:

{
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/d1a65dde-72f6-4f88-b800-bfdf1171f2fe";
    fsType = "btrfs";
    options = ["subvol=@"];
  };

  boot.initrd.luks.devices."luks-b2ab300b-5e98-4eca-b4c0-acfd5a7ad033" = {
    device = "/dev/disk/by-uuid/b2ab300b-5e98-4eca-b4c0-acfd5a7ad033";
    allowDiscards = true;
    bypassWorkqueues = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/B26D-DC6A";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/ad423bf9-bec1-4c9d-ab94-5b67ace276df"; }
  ];

  services.btrfs.autoScrub.enable = true;
}
