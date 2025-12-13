{ config, lib, pkgs, inputs, ... }:

let
  oldpkgs = import inputs.nixpkgs-oldstable {
    system = pkgs.stdenv.hostPlatform.system;
  };
in

{
  imports = [
    inputs.self.lib.homeModules.tirr
  ];

  home.packages = with pkgs; [
    calibre
    oldpkgs.deadbeef
    ffmpeg-full
    jetbrains.idea-community-bin
    krita
    libjxl-dev
    loupe
    mpv
    prismlauncher
    ungoogled-chromium
    vesktop
  ];

  home.language.base = "ko_KR.UTF-8";

  fonts.fontconfig = {
    enable = true;
    defaultFonts = import ../profiles/default-fonts.nix;
  };

  programs.alacritty = {
    enable = true;
    settings = {
      window.dimensions = {
        lines = 40;
        columns = 120;
      };
      window.padding = {
        x = 4;
        y = 4;
      };
      window.dynamic_padding = true;

      font.size = 12;

      colors = {
        normal = {
          black = "#2b2b2b";
          red = "#e5848c";
          green = "#75b168";
          yellow = "#c9983f";
          blue = "#6ca4eb";
          magenta = "#cf88c8";
          cyan = "#00b5b5";
          white = "#b7b7b7";
        };
        bright = {
          black = "#4a4a4a";
          red = "#feb9bd";
          green = "#acd5a3";
          yellow = "#ffd787";
          blue = "#a8ceff";
          magenta = "#ecbbe7";
          cyan = "#86d8d7";
          white = "#e8e8e8";
        };

        primary = {
          foreground = "#cecece";
          bright_foreground = "#e8e8e8";
          background = "#1f1f1f";
        };

        cursor = {
          text = "#1f1f1f";
          cursor = "#cecece";
        };
      };

      keyboard.bindings = [
        {
          mods = "Alt";
          key = "Enter";
          action = "ToggleFullscreen";
        }
      ];
    };
  };

  programs.ssh.enable = true;
  programs.ssh.enableDefaultConfig = false;
  programs.ssh.matchBlocks = {
    lunaere = {
      host = "lunaere-tirrsmb";
      hostname = "10.128.0.1";
      user = "tirrsmb";
      identityFile = "${config.home.homeDirectory}/.ssh/tirrsmb";
    };

    aws = {
      host = "lydie.mitir.social suelle.mitir.social";
      user = "ec2-user";
      identityAgent = "${config.home.homeDirectory}/.1password/agent.sock";
    };
  };

  xdg.configFile."rclone/lunaere.conf".text = ''
[lunaere]
type = sftp
host = 10.128.0.1
user = tirrsmb
key_file = ${config.home.homeDirectory}/.ssh/tirrsmb
  '';

  systemd.user.services.rclone-lunaere = {
    Unit = {
      Description = "Mount lunaere.tirr.network";
      After = ["network-online.target"];
    };

    Service = {
      Type = "notify";
      ExecStartPre = "/run/current-system/sw/bin/mkdir -p %h/lunaere-ssh";
      ExecStart = "${pkgs.rclone}/bin/rclone --config=%h/.config/rclone/lunaere.conf --vfs-cache-mode writes --ignore-checksum mount \"lunaere:/srv/data\" \"lunaere-ssh\"";
      ExecStop="/run/wrappers/bin/fusermount -u %h/lunaere-ssh/%i";
      Environment = ["PATH=/run/wrappers/bin:$PATH"];
    };

    Install.WantedBy = ["default.target"];
  };
}
