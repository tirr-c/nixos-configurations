{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, ... }: rec {
    nixosConfigurations.chise = nixpkgs.lib.nixosSystem {
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

    lib =
      let
        usersLib = import ./users/lib.nix inputs;
      in
      usersLib;
  };
}
