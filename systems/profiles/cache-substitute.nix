{ ... }:

{
  nix.settings = {
    substituters = [
      "http://nix-store-cache.internal.tirr.network?priority=30"
    ];
    trusted-public-keys = [
      (builtins.readFile ../plachta/nix-store-public-key.pub)
    ];
  };
}
