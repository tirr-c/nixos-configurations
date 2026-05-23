{ config, ... }:

let
  cfg = config.services.forgejo;
  srv = cfg.settings.server;
in

{
  services.forgejo = {
    enable = true;
    database.type = "postgres";

    settings = {
      server = {
        DOMAIN = "git.tirr.dev";
        ROOT_URL = "https://${srv.DOMAIN}/";
        HTTP_PORT = 54902;

        DISABLE_SSH = true;
      };

      service.DISABLE_REGISTRATION = true;

      DEFAULT = {
        APP_NAME = "Tirr Forge";
      };

      "ui.meta" = {
        AUTHOR = "Tirr";
        DESCRIPTION = "Tirr's self-hosted code forge";
      };
    };
  };

  services.caddy.virtualHosts.${srv.DOMAIN} = {
    extraConfig = ''
      request_body {
        max_size 512M
      }
      reverse_proxy localhost:${toString srv.HTTP_PORT}
    '';
  };
}
