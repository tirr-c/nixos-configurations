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
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix?ref=release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, nur, ... }:
    let
      lib =
        let
          usersLib = import ./users/lib.nix inputs;
          devShellsLib = import ./devShells/lib.nix inputs;
        in
        usersLib // devShellsLib;

      overlays = import ./overlays inputs;

      commonSpecialArgs = {
        inherit inputs;
        flakeLib = lib;
      };

      nixosConfigurations = {
        chise = nixpkgs.lib.nixosSystem {
          specialArgs = {
            host = "chise";
          } // commonSpecialArgs;

          modules = [
            ./systems/chise/default.nix
          ];
        };

        herta = nixpkgs.lib.nixosSystem {
          specialArgs = {
            host = "herta";
          } // commonSpecialArgs;

          modules = [
            nur.modules.nixos.default
            ./systems/herta/default.nix
          ];
        };

        chihiro = nixpkgs.lib.nixosSystem {
          specialArgs = {
            host = "chihiro";
          } // commonSpecialArgs;

          modules = [
            ./systems/chihiro/default.nix
          ];
        };
      };

      devShells = import ./devShells/default.nix inputs;
    in

    { inherit nixosConfigurations lib overlays; }
    // devShells;
}
