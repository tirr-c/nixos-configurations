inputs@{ nixpkgs, home-manager, ... }:

let
  inherit (home-manager.lib) homeManagerConfiguration;
in

rec {
  homeModules = {
    tirr = ./tirr/config.nix;
  };

  mkHomeConfiguration =
    { system, name, extraModules ? [] }:
    let
      pkgs = import nixpkgs { localSystem = system; };
    in
    homeManagerConfiguration {
      inherit pkgs;

      modules = [ homeModules.${name} ] ++ extraModules;

      extraSpecialArgs = { inherit inputs; };
    };
}
