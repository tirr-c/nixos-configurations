{ ... }:

{
  fileSystems."/" = {
    device = "/dev/mapper/luks-277772ef-45b7-4cb1-8caa-4e86bbc6852e";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."luks-277772ef-45b7-4cb1-8caa-4e86bbc6852e".device = "/dev/disk/by-uuid/277772ef-45b7-4cb1-8caa-4e86bbc6852e";

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0D48-0DE4";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  swapDevices = [];
}
