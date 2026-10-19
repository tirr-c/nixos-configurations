{ pkgs, ... }:

{
  users.users = {
    chihiro = {
      isNormalUser = true;
      description = "Chihiro";
      extraGroups = ["wheel"];
    };

    tirr = {
      isNormalUser = true;
      description = "Tirr";
      extraGroups = ["wheel"];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keyFiles = [ ../../users/tirr/authorized_keys ];
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
