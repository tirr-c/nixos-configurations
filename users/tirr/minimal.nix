{ config, lib, pkgs, ... }:

{
  home.username = "tirr";

  home.packages = with pkgs; [
    eza
    jq
  ];

  home.file = {
    p10k = {
      enable = true;
      source = ./p10k.zsh;
      target = ".p10k.zsh";
    };
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;

    nix-direnv.enable = true;
  };

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

  programs.git = {
    enable = true;
    ignores = [
      ".python-version"
      ".node-version"
      ".npmrc"
      ".envrc"
      ".direnv"
    ];
    settings = {
      init.defaultBranch = "main";
      merge.conflictStyle = "diff3";
    };
  };

  programs.git-credential-oauth.enable = true;
  programs.git.settings.credential = {
    "https://git.tirr.dev" = {
      oauthClientId = "4cd1e89a-39fe-42d5-a5de-e0bef6865582";
      oauthAuthURL = "/login/oauth/authorize";
      oauthTokenURL = "/login/oauth/access_token";
    };
  };

  programs.htop.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins; [
      editorconfig-vim
      vim-better-whitespace
      vim-sensible
    ];

    extraConfig = (lib.fileContents ./vim/vimrc) + "\n";
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
}
