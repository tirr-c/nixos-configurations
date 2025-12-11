{ config, pkgs, lib, ... }:

let
  tirrcolo = pkgs.callPackage ../../packages/tirrcolo {};
in

{
  home.username = "tirr";
  home.homeDirectory = "/home/tirr";

  home.packages = with pkgs; [
    eza
    jq
    kubectl
    kubectx
    kubelogin-oidc
    nixd
    p7zip
  ] ++ lib.optionals (!pkgs.stdenv.isDarwin) (with pkgs; [
    mosh
  ]);

  home.file = {
    p10k = {
      enable = true;
      source = ./p10k.zsh;
      target = ".p10k.zsh";
    };
  };

  programs.awscli.enable = true;

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;

    nix-direnv.enable = true;
  };

  programs.fastfetch.enable = true;

  programs.fd = {
    enable = true;

    ignores = [ ".git/" ];
  };

  programs.fzf = rec {
    enable = true;

    defaultCommand = "fd --color=always --type f --hidden --follow";
    defaultOptions = [ "--ansi" "--height 40%" ];
    changeDirWidgetCommand = "fd --color=always --type t --hidden --follow";
    fileWidgetCommand = defaultCommand;
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      light = false;
      line-numbers = true;
      navigate = true;
      side-by-side = true;
    };
  };

  programs.git = {
    enable = true;
    ignores = [
      ".python-version"
      ".node-version"
      ".npmrc"
      ".envrc"
      ".direnv"
    ];
    signing = {
      key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
      signByDefault = true;
    };
    settings = {
      init.defaultBranch = "main";
      merge.conflictStyle = "diff3";
      gpg.format = "ssh";
    };
  };

  programs.htop = {
    enable = true;
    settings = {
      fields = "0 48 17 18 38 39 40 2 46 47 49 1";
      sort_key = "46";
      sort_direction = "1";
      tree_sort_key = "0";
      tree_sort_direction = "1";
      hide_kernel_threads = "1";
      hide_userland_threads = "1";
      shadow_other_users = "1";
      show_thread_names = "0";
      show_program_path = "1";
      highlight_base_name = "1";
      highlight_deleted_exe = "1";
      highlight_megabytes = "1";
      highlight_changes = "0";
      find_comm_in_cmdline = "1";
      strip_exe_from_cmdline = "1";
      show_merged_command = "1";
      tree_view = "1";
      tree_view_always_by_pid = "0";
      header_margin = "1";
      show_cpu_usage = "1";
      show_cpu_frequency = "1";
      show_cpu_temperature = "1";
      degree_fahrenheit = "0";
      account_guest_in_cpu_meter = "1";
      enable_mouse = "1";
      header_layout = "two_50_50";
      column_meters_0 = "LeftCPUs Memory PressureStallIOSome PressureStallMemorySome";
      column_meter_modes_0 = "1 1 2 2";
      column_meters_1 = "RightCPUs Tasks LoadAverage Uptime";
      column_meter_modes_1 = "1 2 2 2";
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    withNodeJs = true;

    plugins =
      let
        vimPlugins = with pkgs.vimPlugins; [
          editorconfig-vim
          fzfWrapper
          fzf-vim
          tirrcolo
          vim-airline
          vim-airline-themes
          vim-better-whitespace
          vim-sensible
        ] ++ [
          {
            plugin = pkgs.vimPlugins.nvim-lspconfig;
            type = "lua";
            config = lib.fileContents ./vim/lsp.lua;
          }
          {
            plugin = pkgs.vimPlugins.nvim-notify;
            type = "lua";
            config = lib.fileContents ./vim/notify.lua;
          }
        ];
        syntaxPlugins = with pkgs.vimPlugins; [
          rust-vim
          typescript-vim
          vim-javascript
          vim-jsx-pretty
          vim-pug
          vim-terraform
          vim-toml
          vim-vue
        ];
      in
      vimPlugins ++ syntaxPlugins;

    extraConfig =
      let
        files = [
          ./vim/vimrc
          ./vim/airline.vim
          ./vim/fzf.vim
          ./vim/jsx.vim
        ];
        fileContents = builtins.map lib.fileContents files;
      in
      builtins.concatStringsSep "\n" fileContents;
  };

  programs.ripgrep.enable = true;

  programs.tmux = {
    enable = true;

    shortcut = "q";
    baseIndex = 1;
    keyMode = "vi";
    terminal = "tmux-256color";
    escapeTime = 0;
    clock24 = true;

    extraConfig = lib.fileContents ./tmux.conf;
  };

  programs.zsh = {
    enable = true;

    dirHashes = {
      nixos = "$HOME/nixos-configurations";
    };

    shellAliases = {
      mv = "mv -i";
      cp = "cp -i";
      less = "less -SR";
      sl = "ls";
      eza = "eza --group-directories-first --color=always";
      exa = "eza";
      ls = "eza";
      l = "eza -lgab --time-style iso";
      "ㅣ" = "l";
      "니" = "ls";
      "ㅣㄴ" = "ls";
      "ㄴㅣ" = "ls";
    };

    syntaxHighlighting.enable = true;

    plugins = [
      {
        name = "lscolors";
        src = pkgs.fetchFromGitHub {
          owner = "trapd00r";
          repo = "LS_COLORS";
          rev = "20cc87c21f5f54cf86be7e5867af9efc65b8b4e3";
          sha256 = "sha256-/l4LpOBHPvfg6kmLvK96b5pOjEk9wh5QwfH79h5aVpw=";
        };
        file = "lscolors.sh";
      }
      {
        name = "cgitc";
        src = pkgs.fetchFromGitHub {
          owner = "simnalamburt";
          repo = "cgitc";
          rev = "787e22f461cf20c8ac20340fd090d06c622ffe1b";
          sha256 = "sha256-IzLejg888injdK5PgfIyexQwyV5JaMwnaQzSS364uLI=";
        };
        file = "init.zsh";
      }
      {
        name = "zsh-completions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-completions";
          rev = "d24f58d2f187a72697aa2781a730f65732cb2f6b";
          sha256 = "sha256-+NWfTiiqZ7orLYRgpj7Qi1wktCHdR7mw5ohDGYleK0c=";
        };
      }
      {
        name = "powerlevel10k";
        src = pkgs.fetchFromGitHub {
          owner = "romkatv";
          repo = "powerlevel10k";
          rev = "0996a9411824cbfe8fdd8cb17448c94ef891be34";
          sha256 = "sha256-yk2ajJ7ml8z1vIZ0gOp6RFrrRfd6p5P0RorZq9fPO5A=";
        };
        file = "powerlevel10k.zsh-theme";
      }
    ];

    initContent = lib.mkMerge [
      (
        lib.mkBefore ''
          stty stop undef
          export GPG_TTY=$TTY

          if [[ -r "${config.xdg.cacheHome}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
            source "${config.xdg.cacheHome}/p10k-instant-prompt-''${(%):-%n}.zsh"
          fi
        ''
      )
      (
        lib.mkAfter (lib.fileContents ./zshrc)
      )
    ];

    envExtra = ''
      typeset -g FZF_COMPLETION_TRIGGER='\'

      function _fzf_compgen_path() {
          fd --color=always --hidden --follow . "$1"
      }

      function _fzf_compgen_dir() {
          fd --color=always --type d --hidden --follow . "$1"
      }
    '';
  };

  home.stateVersion = "23.11";
  programs.home-manager.enable = true;
}
