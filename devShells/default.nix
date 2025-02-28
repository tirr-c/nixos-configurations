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

      rust-1_84 = mkRustShell {
        toolchainSpec = {
          channel = "1.84.0";
          sha256 = "sha256-lMLAupxng4Fd9F1oDw8gx+qA0RuF7ou7xhNU8wgs0PU=";
        };
        extraComponents = ["rust-src" "rust-analyzer"];
      };

      rust-1_85 = mkRustShell {
        toolchainSpec = {
          channel = "1.85.0";
          sha256 = "sha256-AJ6LX/Q/Er9kS15bn9iflkUwcgYqRQxiOIL2ToVAXaU=";
        };
        extraComponents = ["rust-src" "rust-analyzer"];
      };
    };
  }
)
