{ flakeLib, pkgs, ... }:

{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  users.users.tirr = {
    isNormalUser = true;
    description = "Wonwoo Choi";
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keyFiles = [ ../../users/tirr/authorized_keys ];
  };
  home-manager.users.tirr = import flakeLib.homeModules.tirr;
}
