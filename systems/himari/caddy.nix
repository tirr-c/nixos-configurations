{ ... }:

let
  chihiro = "172.30.1.99";

  hostToPort = {
    "keycloak.veritas.tirr.network" = 8080;
    "outline.veritas.tirr.network" = 56029;
    "photos.veritas.tirr.network" = 54080;
  };
in

{
  services.caddy = {
    enable = true;
    openFirewall = true;

    virtualHosts = builtins.mapAttrs (host: port: {
      useACMEHost = host;
      extraConfig = ''
        reverse_proxy ${chihiro}:${toString port}
      '';
    }) hostToPort;
  };

  security.acme.certs = builtins.mapAttrs (host: port: {}) hostToPort;

  networking.hosts = {
    "127.0.0.1" = builtins.attrNames hostToPort;
  };
}
