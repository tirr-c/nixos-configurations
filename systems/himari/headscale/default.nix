{ config, inputs, ... }:

let
  cfg = config.services.headscale;
  port = toString cfg.port;
  serverUrl = "headscale.veritas.tirr.network";
in

{
  services.headscale = {
    enable = true;
    package = (import inputs.nixpkgs-unstable { system = "aarch64-linux"; }).headscale;

    settings = {
      server_url = "https://${serverUrl}";
      policy = {
        mode = "file";
        path = "${./policy.json}";
      };
      dns = {
        base_domain = "veritas.local";
        override_local_dns = false;
      };
      oidc = {
        issuer = "https://keycloak.veritas.tirr.network/realms/master";
        client_id = "headscale";
        allowed_groups = ["/tailnet"];
        scope = ["openid" "profile" "email" "groups"];
        pkce = {
          enabled = true;
          method = "S256";
        };
      };
    };
  };

  services.caddy.virtualHosts.${serverUrl} = {
    extraConfig = ''
      reverse_proxy localhost:${port}
    '';
  };

  networking.hosts = {
    "127.0.0.1" = [serverUrl];
  };
}
