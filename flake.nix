{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager?ref=release-25.11";
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
      url = "github:ezKEa/aagl-gtk-on-nix?ref=release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "";
    };
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nur, agenix-rekey, ... }:
    let
      lib =
        let
          usersLib = import ./users/lib.nix inputs;
        in
        usersLib;

      overlays = import ./overlays inputs;

      commonSpecialArgs = {
        inherit inputs;
        flakeLib = lib;
      };

      nixosConfigurations = {
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
            ./modules/nocodb
            ./systems/chihiro/default.nix
          ];
        };
      };
    in

    {
      inherit nixosConfigurations lib overlays;

      agenix-rekey = agenix-rekey.configure {
        userFlake = self;
        nixosConfigurations = self.nixosConfigurations;
        agePackage = p: p.age;
      };
    };
}
