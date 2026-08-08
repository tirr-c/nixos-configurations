{ config, ... }:

{
  services.keycloak = {
    enable = true;
    database.passwordFile = config.age.secrets.keycloak-db.path;
    settings = {
      hostname = "https://keycloak.veritas.tirr.network";
      http-enabled = true;
      http-host = "0.0.0.0";
      http-port = 8080;
      proxy-headers = "xforwarded";
      proxy-trusted-addresses = "127.0.0.0/8,172.30.1.68";
    };
  };
}
