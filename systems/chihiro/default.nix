{ pkgs, lib, inputs, ... }:

{
  imports = [
    ../profiles/base.nix
    ../profiles/graphical.nix
    ../profiles/nvidia.nix
    ../profiles/gaming.nix
    ../profiles/fonts.nix
    ./hardware-configuration.nix
    ./disks.nix
    ./papermc.nix
    ./calibre.nix
    ./jellyfin.nix
    ./users.nix
  ];

  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;

  boot.initrd.kernelModules = lib.mkAfter ["nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm"];

  networking.useNetworkd = true;
  networking.hostId = "17648f8c";
  systemd.network = {
    enable = true;
    networks = {
      "99-ethernet" = {
        matchConfig.Name = "eth*";
        DHCP = "yes";
      };
    };
  };
  services.networkd-dispatcher = {
    enable = true;
    rules = {
      tailscale-offload = {
        onState = ["routable"];
        script = ''
          ${lib.getExe pkgs.ethtool} -K "$IFACE" rx-udp-gro-forwarding on rx-gro-list off
        '';
      };
    };
  };
  networking.firewall = {
    interfaces.enp4s0 = {
      allowedTCPPorts = [
        8080
      ];
    };
  };

  time.timeZone = "Asia/Seoul";

  i18n.defaultLocale = "ko_KR.UTF-8";
  i18n.supportedLocales = [
    "C.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
    "ko_KR.UTF-8/UTF-8"
    "ja_JP.UTF-8/UTF-8"
  ];

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "chihiro";

  programs.firefox.enable = true;

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.git.enable = true;

  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    alacritty
    btrfs-progs
    curl
    git
    vim
  ];

  services.fwupd.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      KbdInteractiveAuthentication = false;
    };
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
  };

  services.keycloak = {
    enable = true;
    database.passwordFile = "/etc/nixos/secrets/keycloak-db";
    settings = {
      hostname = "https://keycloak.veritas.tirr.network";
      http-enabled = true;
      http-host = "0.0.0.0";
      http-port = 8080;
      proxy-headers = "xforwarded";
      proxy-trusted-addresses = "127.0.0.0/8,172.30.1.68";
    };
  };

  security.sudo.wheelNeedsPassword = false;

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "schedutil";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
