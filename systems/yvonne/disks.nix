{ ... }:

{
  fileSystems."/" = {
    device = "/dev/mapper/luks-60337031-2ea7-4069-9658-e17b9e7189b8";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."luks-60337031-2ea7-4069-9658-e17b9e7189b8".device = "/dev/disk/by-uuid/60337031-2ea7-4069-9658-e17b9e7189b8";

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/98D6-00F6";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  swapDevices = [];
}
