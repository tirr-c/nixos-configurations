{ config, inputs, ... }:

let
  pkgsUnstable = import inputs.nixpkgs-unstable {
    system = config.nixpkgs.hostPlatform.system;
    config = {
      allowUnfree = true;
    };
  };
in

{
  services.outline = {
    enable = true;
    package = pkgsUnstable.outline;

    publicUrl = "https://outline.veritas.tirr.network";
    port = 56029;
    storage.storageType = "local";
    maximumImportSize = 50 * 1024 * 1024;

    oidcAuthentication = {
      clientId = "outline";
      clientSecretFile = config.age.secrets.outline-oidc-secret.path;
      authUrl = "https://keycloak.veritas.tirr.network/realms/master/protocol/openid-connect/auth";
      tokenUrl = "https://keycloak.veritas.tirr.network/realms/master/protocol/openid-connect/token";
      userinfoUrl = "https://keycloak.veritas.tirr.network/realms/master/protocol/openid-connect/userinfo";
      displayName = "Keycloak";
    };

    defaultLanguage = "ko_KR";
  };
}
