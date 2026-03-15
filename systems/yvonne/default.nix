{ lib, pkgs, ... }:

{
  imports = [
    ../profiles/base.nix
    ../profiles/nvidia.nix
    ./hardware-configuration.nix
    ./disks.nix
    ./users.nix
  ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.cudaSupport = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;
  boot.kernelParams = ["console=ttyS0,115200n8"];

  boot.kernelPackages = pkgs.linuxPackages_6_18;

  hardware.nvidia.nvidiaPersistenced = true;
  hardware.nvidia.nvidiaSettings = lib.mkForce false;

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

  # ComfyUI
  networking.firewall.allowedTCPPorts = [8188];

  time.timeZone = "Asia/Seoul";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [
    "C.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
    "ko_KR.UTF-8/UTF-8"
    "ja_JP.UTF-8/UTF-8"
  ];

  environment.systemPackages = with pkgs; [
    vim
    curl
    git
    uv
  ];

  services.openssh = {
    enable = true;
    settings = {
      KbdInteractiveAuthentication = false;
    };
  };

  services.qemuGuest.enable = true;

  programs.nix-ld.enable = true;
  programs.zsh.enable = true;

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
