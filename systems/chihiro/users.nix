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

    papermc =
      let
        papermc = pkgs.papermc.override {
          version = "1.21.4-214";
          hash = "";
        };
      in
      {
        isSystemUser = true;
        description = "PaperMC";
        group = "papermc";
        home = "/srv/minecraft";
        packages = [
          papermc
        ];
      };
  };

  users.groups = {
    papermc = {};
  };
}
