{ lib, ... }:

{
  # NVIDIA driver
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement = {
      enable = true;
      finegrained = false;
    };
    open = true;
    nvidiaSettings = true;
  };

  # https://github.com/NixOS/nixpkgs/issues/334180
  boot.kernelModules = lib.mkAfter ["nvidia_uvm"];
}
