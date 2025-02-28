{
  fenix,
  pkgs,
  toolchainSpec,
  extraComponents ? [],
  extraTargets ? [],
  system,

  openssl ? pkgs.openssl,
  pkg-config ? pkgs.pkg-config,
  ...
}:

let
  fenix' = fenix.packages.${system};
  toolchain = fenix'.toolchainOf toolchainSpec;
  extraComponents' = map (component: toolchain.${component}) extraComponents;
  extraTargets' = map (target: (fenix'.targets.${target}.toolchainOf toolchainSpec).rust-std) extraTargets;
  completeToolchain = fenix'.combine ([toolchain.defaultToolchain] ++ extraComponents' ++ extraTargets');

  # Copied from naersk
  pkgsDarwin = with pkgs.darwin; [
    Security
    apple_sdk.frameworks.CoreServices
    apple_sdk.frameworks.SystemConfiguration
    cf-private
    libiconv
  ];

  computeName = { channel, date ? null, ... }: (
    if date == null then channel else "${channel}-${date}"
  );
in

pkgs.mkShell {
  name = "rust-${computeName toolchainSpec}";
  packages = [
    completeToolchain
    openssl
    pkg-config
  ] ++ (pkgs.lib.optionals pkgs.stdenv.isDarwin pkgsDarwin);
}
