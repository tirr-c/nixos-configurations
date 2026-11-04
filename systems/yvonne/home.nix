{ config, inputs, pkgs, ... }:

let
  pkgsUnstable = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
  };

  pi-coding-agent = pkgsUnstable.pi-coding-agent.override {
    inherit (pkgs) buildNpmPackage;
  };
in

{
  imports = [
    ../../users/tirr/minimal.nix
    ../../users/tirr/pi
    ../../modules/pi-coding-agent.nix
  ];

  home.packages = with pkgs; [
    mosh
    ty
    uv
  ];

  programs.git.signing = {
    format = "ssh";
    key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
    signByDefault = true;
  };

  programs.gh.enable = true;

  programs.neovim.plugins = with pkgs.vimPlugins; [
    rust-vim
  ];

  programs.pi-coding-agent = {
    enable = true;
    package = pi-coding-agent;
    extraPackages = [
      pkgs.nodejs
      pkgs.python3
      pkgs.bubblewrap
    ];
  };

  programs.ssh.enable = true;
  programs.ssh.enableDefaultConfig = false;
}
