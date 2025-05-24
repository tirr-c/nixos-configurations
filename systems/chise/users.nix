{ pkgs, inputs, ... }:

{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  users.users.tirr = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keyFiles = [ ../../users/tirr/authorized_keys ];
  };
  home-manager.users.tirr = import inputs.self.lib.homeModules.tirr;
}
