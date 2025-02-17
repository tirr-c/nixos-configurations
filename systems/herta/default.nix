{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ../default.nix
    ./hardware-configuration.nix
    ./graphical.nix
    ./users.nix
    ./gaming.nix
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

  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = ["*"];
        settings = {
          main = {
            rightalt = "hangeul";
            rightcontrol = "hanja";
          };
        };
      };
    };
  };

  fonts = {
    packages = with pkgs; [
      cascadia-code
      pretendard
      pretendard-jp
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      twemoji-color-font
    ];

    fontDir.enable = true;
    fontconfig = {
      allowBitmaps = false;
      cache32Bit = true;
      defaultFonts = import ./default-fonts.nix;
    };
  };

  hardware.pulseaudio.enable = false;
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

  programs.firefox = {
    enable = true;
    nativeMessagingHosts.packages =
      let
        pipewire-screenaudio = inputs.pipewire-screenaudio.packages.${pkgs.system}.default;
      in
      [
        pipewire-screenaudio
      ];
  };

  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    btrfs-progs
  ];

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = ["tirr"];
  };

  services.fwupd.enable = true;

  programs.zsh.enable = true;

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
