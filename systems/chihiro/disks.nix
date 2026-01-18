{ ... }:

{
  boot.supportedFilesystems = ["zfs"];
  boot.zfs = {
    forceImportRoot = false;
    devNodes = "/dev/disk/by-id";
    extraPools = ["veritas"];
    requestEncryptionCredentials = ["veritas"];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/c7668a70-fb50-4415-afd9-0476188cd2c7";
    fsType = "btrfs";
    options = [
      "noatime"
      "subvol=@"
    ];
  };

  #boot.initrd.supportedFilesystems = ["vfat"];
  boot.initrd.luks.devices."luks-a20b886e-ee6b-4cdf-91b4-5630b58c7c58" = {
    device = "/dev/disk/by-uuid/a20b886e-ee6b-4cdf-91b4-5630b58c7c58";
    #keyFile = "/tmp/keys/key-0:UUID=4FC5-A53F";
    bypassWorkqueues = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/3554-562C";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/f007fd92-495b-4b42-8682-1987079dd30d"; }
  ];

  services.btrfs.autoScrub.enable = true;
  services.zfs.autoScrub.enable = true;
}
