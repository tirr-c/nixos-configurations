{ inputs, lib, ... }:

{
  imports = [
    inputs.lix-module.nixosModules.lixFromNixpkgs
  ];

  nix.settings = {
    extra-substituters = lib.mkAfter [
      "https://cache.lix.systems"
    ];
    extra-trusted-public-keys = lib.mkAfter [
      "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
    ];
  };
}
