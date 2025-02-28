{ pkgs, ... }:

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
  };
}
