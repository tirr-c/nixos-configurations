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
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = inputs@{ self, nixpkgs, nur, agenix-rekey, nixos-hardware, ... }:
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
            ./systems/herta
          ];
        };

        chihiro = nixpkgs.lib.nixosSystem {
          specialArgs = {
            host = "chihiro";
          } // commonSpecialArgs;

          modules = [
            ./modules/frostracker
            ./modules/nocodb
            ./systems/chihiro
          ];
        };

        perlica = nixpkgs.lib.nixosSystem {
          specialArgs = {
            host = "perlica";
          } // commonSpecialArgs;

          modules = [
            nixos-hardware.nixosModules.raspberry-pi-4
            ./systems/perlica
          ];
        };

        plachta = nixpkgs.lib.nixosSystem {
          specialArgs = {
            host = "plachta";
          } // commonSpecialArgs;

          modules = [
            ./systems/plachta
          ];
        };

        xaihi = nixpkgs.lib.nixosSystem {
          specialArgs = {
            host = "xaihi";
          } // commonSpecialArgs;

          modules = [
            ./modules/out-of-your-element
            ./systems/xaihi
          ];
        };

        yvonne = nixpkgs.lib.nixosSystem {
          specialArgs = {
            host = "yvonne";
          } // commonSpecialArgs;

          modules = [
            ./systems/yvonne
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
