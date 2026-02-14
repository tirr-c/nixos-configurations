{ config, ... }:

{
  boot = {
    extraModulePackages = [config.boot.kernelPackages.evdi];
    initrd.kernelModules = ["evdi"];
  };
}
