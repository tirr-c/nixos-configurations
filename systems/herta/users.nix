{ pkgs, inputs, ... }:

{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = {
    inherit inputs;
  };

  users.users.tirr = {
    isNormalUser = true;
    description = "Wonwoo Choi";
    extraGroups = [ "wheel" "keyd" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keyFiles = [ ../../users/tirr/authorized_keys ];
  };
  home-manager.users.tirr = ./home.nix;

  users.groups = {
    keyd = {};
  };
}
