{
  fenix,
  manifestHash,
  pkgs,
  rustChannel,
  system,

  openssl ? pkgs.openssl,
  pkg-config ? pkgs.pkg-config,
  ...
}:

let
  manifestUrl = "https://static.rust-lang.org/dist/channel-rust-${rustChannel}.toml";
  manifest = pkgs.fetchurl {
    url = manifestUrl;
    hash = manifestHash;
  };
  toolchain = fenix.packages.${system}.fromManifestFile "${manifest}";
  inherit (toolchain) completeToolchain;

  # Copied from naersk
  pkgsDarwin = with pkgs.darwin; [
    Security
    apple_sdk.frameworks.CoreServices
    apple_sdk.frameworks.SystemConfiguration
    cf-private
    libiconv
  ];
in

pkgs.mkShell {
  name = "rust-${rustChannel}";
  packages = [
    completeToolchain
    openssl
    pkg-config
  ] ++ (pkgs.lib.optionals pkgs.stdenv.isDarwin pkgsDarwin);
}
