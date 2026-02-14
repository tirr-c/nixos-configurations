{ pkgs, ... }:

{
  imports = [
    ./evdi.nix
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Plasma 6
  environment.systemPackages = [
    (pkgs.callPackage ../../packages/sddm-arona/default.nix {})
    pkgs.kdePackages.sddm-kcm
  ];
  services.xserver.enable = false;
  services.displayManager.sddm = {
    enable = true;
    wayland = {
      enable = true;
      compositor = "kwin";
    };

    theme = "arona";
  };
  services.desktopManager.plasma6.enable = true;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    kate
  ];

  # Plymouth and silent boot
  boot.plymouth = {
    enable = true;
    theme = "nixos-bgrt";
    themePackages = with pkgs; [
      nixos-bgrt-plymouth
    ];

    font = "${pkgs.pretendard}/share/fonts/opentype/Pretendard-Regular.otf";
  };
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
  boot.kernelParams = [
    "quiet"
    "splash"
    "boot.shell_on_fail"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
  ];
  boot.loader.timeout = 0;
}
