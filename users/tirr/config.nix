{ config, pkgs, lib, ... }:

let
  tirrcolo = pkgs.callPackage ../../packages/tirrcolo {};
in

{
  imports = [
    ./minimal.nix
  ];

  home.homeDirectory = "/home/tirr";

  home.packages = with pkgs; [
    kubectl
    kubectx
    kubelogin-oidc
    nixd
    p7zip
  ] ++ lib.optionals (!pkgs.stdenv.isDarwin) (with pkgs; [
    mosh
  ]);

  programs.awscli.enable = true;

  programs.fastfetch.enable = true;

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

  programs.git.signing = {
    format = "ssh";
    key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
    signByDefault = true;
  };

  programs.htop.settings = {
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

  programs.neovim = {
    withNodeJs = true;

    plugins =
      let
        vimPlugins = with pkgs.vimPlugins; [
          fzfWrapper
          fzf-vim
          tirrcolo
          vim-airline
          vim-airline-themes
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
          vim-javascript
          vim-jsx-pretty
          vim-terraform
          vim-toml
          vim-vue
        ];
      in
      vimPlugins ++ syntaxPlugins;

    extraConfig =
      let
        files = [
          ./vim/airline.vim
          ./vim/fzf.vim
          ./vim/jsx.vim
        ];
        fileContents = builtins.map lib.fileContents files;
      in
      lib.mkMerge [
        (lib.mkAfter "colo tirr\n")
        (lib.mkAfter ((builtins.concatStringsSep "\n" fileContents) + "\n"))
      ];
  };

  programs.zsh.dirHashes = {
    nixos = "$HOME/nixos-configurations";
  };

  programs.home-manager.enable = true;
}
