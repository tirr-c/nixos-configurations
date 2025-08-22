{ pkgs, lib, ... }:

{
  imports = [
    ../profiles/base.nix
    ../profiles/graphical.nix
    ../profiles/gaming.nix
    ../profiles/fonts.nix
    ./hardware-configuration.nix
    ./waydroid.nix
    ./disks.nix
    ./users.nix
  ];

  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;

  networking.useNetworkd = true;
  networking.wireless.iwd.enable = true;

  hardware.bluetooth.enable = true;

  systemd.network = {
    enable = true;
    networks = {
      "99-ethernet" = {
        matchConfig.Name = "eth*";
        DHCP = "yes";
      };
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

  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = ["*"];
        settings = {
          main = {
            leftshift = "leftshift";
            rightalt = "hangeul";
            rightcontrol = "hanja";
            rightshift = "rightshift";
          };
        };
      };
    };
  };
  systemd.services.keyd.serviceConfig.CapabilityBoundingSet = lib.mkAfter ["CAP_SETGID"];

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    wireplumber = {
      enable = true;
      extraConfig = {
        "10-bluez" = {
          "monitor.bluez.properties" = {
            "bluez5.enable-sbc-xq" = true;
            "bluez5.enable-msbc" = true;
            "bluez5.enable-hw-volume" = true;
          };
        };
      };
    };
  };

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    btrfs-progs
    wineWowPackages.staging
    winetricks
  ];

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = ["tirr"];
  };

  services.fwupd.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      KbdInteractiveAuthentication = false;
    };
  };

  services.tailscale.enable = true;

  services.sunshine = {
    enable = true;
    capSysAdmin = true;
  };

  programs.zsh.enable = true;

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      zlib
      zstd
      stdenv.cc.cc
      curl
      openssl
      attr
      libssh
      bzip2
      libxml2
      acl
      libsodium
      util-linux
      xz
      systemd
    ];
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "schedutil";
  };

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="pci", DRIVER=="pcieport", ATTR{power/wakeup}="disabled"
  '';

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
