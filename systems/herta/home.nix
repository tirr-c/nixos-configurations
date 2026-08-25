{ config, pkgs, inputs, ... }:

let
  pkgsUnstable = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
  };
in

{
  imports = [
    inputs.self.lib.homeModules.tirr
  ];

  home.packages = with pkgs; [
    calibre
    deadbeef
    ffmpeg-full
    jetbrains.idea
    krita
    libjxl-dev
    loupe
    mpv
    prismlauncher
    ungoogled-chromium
    uv
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

  programs.pi-coding-agent = {
    enable = true;
    package = pkgsUnstable.pi-coding-agent;
    extraPackages = [
      pkgsUnstable.nodejs
      pkgs.python3
      pkgs.qemu
    ];

    settings = {
      defaultProvider = "openai";
      defaultModel = "gpt-5.6-luna";
      defaultThinkingLevel = "xhigh";
      enabledModels = [
        "gpt-5.6-*"
      ];

      showCacheMissNotices = true;

      collapseChangelog = true;
      enableInstallTelemetry = false;
      tuiMode = "fullscreen";
      fullscreenExitOutput = "resume-hint";

      defaultTools = [
        "read"
        "bash"
        "edit"
        "write"
        "grep"
        "find"
        "ls"
      ];
    };

    keybindings =
      let
        esc = ["escape" "ctrl+["];
      in
      {
        "app.interrupt" = esc;
        "tui.select.cancel" = esc;
        "tui.altScreen.halfPageUp" = "ctrl+b";
        "tui.altScreen.halfPageDown" = "ctrl+f";
        "tui.altScreen.lineUp" = "ctrl+up";
        "tui.altScreen.lineDown" = "ctrl+down";
        "tui.altScreen.search" = "ctrl+/";
        "tui.altScreen.searchClose" = esc;
      };
  };

  programs.ssh.enable = true;
  programs.ssh.enableDefaultConfig = false;
  programs.ssh.settings = {
    "plachta-tirrsmb" = {
      User = "tirrsmb";
      HostName = "plachta.tirr.local";
      IdentityFile = "${config.home.homeDirectory}/.ssh/tirrsmb";
    };

    "lydie.mitir.social suelle.mitir.social" = {
      User = "ec2-user";
      IdentityAgent = "${config.home.homeDirectory}/.1password/agent.sock";
    };
  };

  xdg.configFile."rclone/plachta.conf".text = ''
[plachta]
type = sftp
host = plachta.tirr.local
user = tirrsmb
key_file = ${config.home.homeDirectory}/.ssh/tirrsmb
  '';

  systemd.user.services.rclone-plachta = {
    Unit = {
      Description = "Mount plachta.tirr.local";
      After = ["network-online.target"];
    };

    Service = {
      Type = "notify";
      ExecStartPre = "/run/current-system/sw/bin/mkdir -p %h/lunaere-ssh";
      ExecStart = "${pkgs.rclone}/bin/rclone --config=%h/.config/rclone/plachta.conf --vfs-cache-mode writes --ignore-checksum mount \"plachta:/srv/data\" \"lunaere-ssh\"";
      ExecStop="/run/wrappers/bin/fusermount -u %h/lunaere-ssh/%i";
      Environment = ["PATH=/run/wrappers/bin:$PATH"];
    };

    Install.WantedBy = ["default.target"];
  };
}
