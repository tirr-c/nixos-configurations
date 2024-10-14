{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, ... }:
    let
      lib =
        let
          usersLib = import ./users/lib.nix inputs;
        in
        usersLib;

      nixosConfigurations = {
        chise = nixpkgs.lib.nixosSystem {
          specialArgs = {
            host = "chise";
            useLix = true;
            inherit inputs;
            flakeLib = lib;
          };

          modules = [
            ./systems/chise/default.nix
          ];
        };
      };

      devShells = import ./devShells/default.nix inputs;
    in

    { inherit nixosConfigurations lib; }
    // devShells;
}
