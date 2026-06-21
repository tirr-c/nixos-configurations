{ config, ... }:

{
  services.harmonia.cache = {
    enable = true;
    signKeyPaths = [config.age.secrets.nix-store-private-key.path];
    settings = {
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
      @target {
        not path /metrics
      }
      reverse_proxy @target 127.0.0.1:5000
    '';
  };

  networking.firewall = {
    allowedTCPPorts = [80 5000];
  };
}
