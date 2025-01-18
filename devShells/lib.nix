{ fenix, nixpkgs, ... }:

let
  bindSystem = f: system: (
    let
      pkgs = import nixpkgs { localSystem = system; };
    in
    f { inherit system pkgs; }
  );
  mkNodeJsShell = bindSystem (
    { pkgs, ... }: pkgs.callPackage ./nodejs.nix
  );
  mkRustShell = bindSystem (
    { system, pkgs, ... }: args: pkgs.callPackage ./rust.nix ({ inherit fenix system; } // args)
  );
in

{
  inherit mkNodeJsShell mkRustShell;
}
