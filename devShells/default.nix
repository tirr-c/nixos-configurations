{ flake-utils, nixpkgs, ... }:

flake-utils.lib.eachDefaultSystem (
  system:
  let
    pkgs = import nixpkgs { localSystem = system; };
    mkNodeJsShell = pkgs.callPackage ./nodejs.nix;
  in
  {
    devShells = {
      node22 = mkNodeJsShell (
        with pkgs; {
          nodejs = nodejs-slim_22;
          corepack = corepack_22;
        }
      );

      node20 = mkNodeJsShell (
        with pkgs; {
          nodejs = nodejs-slim_20;
          corepack = corepack_20;
        }
      );
    };
  }
)
