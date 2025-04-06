{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    ffmpeg-full
    jetbrains.idea-community-bin
    libjxl
    loupe
    mpv
    prismlauncher
    vesktop
  ];

  home.language.base = "ko_KR.UTF-8";

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
      fcitx5-hangul
    ];
  };

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

      # seoul256
      colors = {
        normal = {
          black = "#4e4e4e";
          red = "#d68787";
          green = "#5f865f";
          yellow = "#d8af5f";
          blue = "#85add4";
          magenta = "#d7afaf";
          cyan = "#87afaf";
          white = "#d0d0d0";
        };
        bright = {
          black = "#626262";
          red = "#d75f87";
          green = "#87af87";
          yellow = "#ffd787";
          blue = "#add4fb";
          magenta = "#ffafaf";
          cyan = "#87d7d7";
          white = "#e4e4e4";
        };

        primary = {
          foreground = "#d0d0d0";
          bright_foreground = "#e4e4e4";
          background = "#121212";
        };

        cursor = {
          text = "#121212";
          cursor = "#d0d0d0";
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
}
