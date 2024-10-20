{ fenix, flake-utils, nixpkgs, ... }:

flake-utils.lib.eachDefaultSystem (
  system:
  let
    pkgs = import nixpkgs { localSystem = system; };
    mkNodeJsShell = pkgs.callPackage ./nodejs.nix;
    mkRustShell = args: pkgs.callPackage ./rust.nix ({ inherit fenix system; } // args);
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

      rust-1_82 = mkRustShell {
        rustChannel = "1.82.0";
        manifestHash = "sha256-yMuSb5eQPO/bHv+Bcf/US8LVMbf/G/0MSfiPwBhiPpk=";
      };
    };
  }
)
