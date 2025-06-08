{ ... }:

{
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/0c0bac2c-6e17-495d-a2d6-680f4c1cc2ba";
    fsType = "btrfs";
    options = ["subvol=@"];
  };

  boot.initrd.luks.devices."luks-d462a9cf-85db-49ae-b94e-ab9e2b19a915" = {
    device = "/dev/disk/by-uuid/d462a9cf-85db-49ae-b94e-ab9e2b19a915";
    allowDiscards = true;
    bypassWorkqueues = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/A052-8DAF";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/4a6925b1-2f3b-4640-9253-e21ff06416c1"; }
  ];

  services.btrfs.autoScrub.enable = true;
}
