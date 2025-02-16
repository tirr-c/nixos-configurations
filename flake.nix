{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.1-2.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager?ref=release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pipewire-screenaudio = {
      url = "github:IceDBorn/pipewire-screenaudio";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, ... }:
    let
      lib =
        let
          usersLib = import ./users/lib.nix inputs;
          devShellsLib = import ./devShells/lib.nix inputs;
        in
        usersLib // devShellsLib;

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

        herta = nixpkgs.lib.nixosSystem {
          specialArgs = {
            host = "herta";
            useLix = false;
            inherit inputs;
            flakeLib = lib;
          };

          modules = [
            ./systems/herta/default.nix
          ];
        };
      };

      devShells = import ./devShells/default.nix inputs;
    in

    { inherit nixosConfigurations lib; }
    // devShells;
}
