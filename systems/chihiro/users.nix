{ pkgs, lib, ... }:

{
  users.users = {
    chihiro = {
      isNormalUser = true;
      description = "Chihiro";
      extraGroups = ["wheel"];
      packages = with pkgs; [
      ];
    };

    tirr = {
      isNormalUser = true;
      description = "Tirr";
      extraGroups = ["wheel"];
      shell = pkgs.zsh;
      packages = with pkgs; [
      ];
    };

    papermc = {
      isSystemUser = true;
      description = "PaperMC";
      group = "papermc";
      home = "/srv/minecraft";
      packages = with pkgs; [
        papermc
      ];
    };
  };

  users.groups = {
    papermc = {};
  };
}
