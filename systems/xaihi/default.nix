{ pkgs, ... }:

{
  imports = [
    ../profiles/base.nix
    ./hardware-configuration.nix
    ./disks.nix
    ./matrix.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.useNetworkd = true;
  networking.interfaces.ens18.useDHCP = true;
  systemd.network = {
    enable = true;
    networks = {
      "40-ens18" = {
        name = "ens18";
        networkConfig.UseDomains = "yes";
      };
    };
  };

  time.timeZone = "Asia/Seoul";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [
    "C.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
    "ko_KR.UTF-8/UTF-8"
    "ja_JP.UTF-8/UTF-8"
  ];

  users.users.tirr = {
    isNormalUser = true;
    description = "Wonwoo Choi";
    extraGroups = ["wheel"];
  };

  environment.systemPackages = with pkgs; [
    vim
    curl
    git
    nodejs
  ];

  services.tailscale.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      KbdInteractiveAuthentication = false;
    };
  };

  services.qemuGuest.enable = true;

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
