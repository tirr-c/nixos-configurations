{ config, ... }:

{
  services.harmonia.cache = {
    enable = true;
    signKeyPaths = [config.age.secrets.nix-store-private-key.path];
    settings = {
      bind = "127.0.0.1:5000";
      enable_compression = true;
    };
  };

  nix.settings.trusted-public-keys = [
    (builtins.readFile ../herta/nix-store-public-key.pub)
  ];

  services.caddy.enable = true;
  services.caddy.globalConfig = ''
    skip_install_trust
  '';

  services.caddy.virtualHosts."http://nix-store-cache.internal.tirr.network" = {
    extraConfig = ''
      reverse_proxy 127.0.0.1:5000
    '';
  };

  networking.firewall = {
    allowedTCPPorts = [80];
  };
}
