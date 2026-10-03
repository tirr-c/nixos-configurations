{ config, ... }:

let
  driverVersion = {
    version = "615.71.09";
    sha256_64bit = "sha256-zc7tIrvrYSSNGm3qvCWWZz46ZQFpjucayNL9wo87cP4=";
    sha256_aarch64 = "sha256-IbekQhE7cFfmnPZaLY9NDYcF7CoNZ+2Qb7sRd4EOgWM=";
    openSha256 = "sha256-3gByMYIwFzRaLdDG+roCEOuKRRJDrljG9AlLnRZTirM=";
    settingsSha256 = "sha256-LK1LU8mDkM/XVRKPBtuOZh9nIP/lGFLAJnmasEX8jhg=";
    persistencedSha256 = "sha256-qPRb+3d88+2RcpUkoBTbjIaImnQ+jX+/6p1vXcJ5geE=";
  };
in
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # NVIDIA driver
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.mkDriver driverVersion;

    modesetting.enable = true;
    powerManagement = {
      enable = true;
      finegrained = false;
    };
    open = true;
    nvidiaSettings = true;
  };
}
