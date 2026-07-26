{ ... }:

let
  chihiro = "172.30.1.99";
in

{
  services.caddy.virtualHosts = {
    "keycloak.veritas.tirr.network" = {
      extraConfig = ''
        reverse_proxy ${chihiro}:8080
      '';
    };

    "outline.veritas.tirr.network" = {
      extraConfig = ''
        reverse_proxy ${chihiro}:56029
      '';
    };

    "photos.veritas.tirr.network" = {
      extraConfig = ''
        reverse_proxy ${chihiro}:54080
      '';
    };
  };

  networking.hosts = {
    "127.0.0.1" = [
      "keycloak.veritas.tirr.network"
      "outline.veritas.tirr.network"
      "photos.veritas.tirr.network"
    ];
  };
}
