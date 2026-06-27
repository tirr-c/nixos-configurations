{ config, ... }:

{
  nix.settings.secret-key-files = [
    config.age.secrets.nix-store-private-key.path
  ];
}
