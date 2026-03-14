{ pkgs, ... }:

{
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/3a4e4311-476f-4967-920c-123f75789332";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/A7FB-BA46";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  fileSystems."/srv/keys" = {
    device = "/dev/disk/by-uuid/4A92-978B";
    fsType = "vfat";
    options = ["ro" "fmask=0077" "dmask=0077"];
  };

  boot.supportedFilesystems = ["zfs"];
  boot.zfs = {
    package = pkgs.zfs_2_4;
    devNodes = "/dev/disk/by-id";
    extraPools = ["plachta"];
    requestEncryptionCredentials = ["plachta/data"];
  };

  systemd.services."zfs-import-plachta".after = ["srv-keys.mount"];
  systemd.services."zfs-import-plachta".wants = ["srv-keys.mount"];

  swapDevices = [];

  services.zfs.autoScrub.enable = true;
}
