inputs@{ flake-utils, nixpkgs, ... }:

flake-utils.lib.eachDefaultSystem (
  system:
  let
    pkgs = import nixpkgs { localSystem = system; };
    lib = import ./lib.nix inputs;
    mkNodeJsShell = lib.mkNodeJsShell system;
    mkRustShell = lib.mkRustShell system;
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

      rust-1_83 = mkRustShell {
        rustChannel = "1.83.0";
        manifestHash = "sha256-s1RPtyvDGJaX/BisLT+ifVfuhDT1nZkZ1NcK8sbwELM=";
      };

      rust-1_84 = mkRustShell {
        rustChannel = "1.84.0";
        manifestHash = "sha256-lMLAupxng4Fd9F1oDw8gx+qA0RuF7ou7xhNU8wgs0PU=";
      };
    };
  }
)
