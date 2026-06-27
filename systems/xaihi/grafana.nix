{ config, ... }:

let
  cfg = config.services.grafana;
  srv = cfg.settings.server;
in

{
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 52357;
        enforce_domain = true;
        enable_gzip = true;
        domain = "grafana.internal.tirr.network";
        root_url = "https://${srv.domain}/";
      };

      # Use the old key for now
      security.secret_key = "SW2YcwTIb9zpOOhoPsMm";
    };
  };

  services.caddy.virtualHosts.${srv.domain} = {
    extraConfig = ''
      tls internal
      reverse_proxy localhost:${toString srv.http_port}
    '';
  };
}
