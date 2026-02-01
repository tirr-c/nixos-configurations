{ config, ... }:

{
  imports = [
    ../../secrets
  ];

  age.identityPaths = ["/etc/agenix-host-key"];
  age.rekey.hostPubkey = ./host-pubkey.pub;

  age.secrets = {
    keycloak-db.rekeyFile = ../../secrets/master/keycloak-db.age;
    zfs-veritas.rekeyFile = ../../secrets/master/zfs-veritas.age;
    outline-oidc-secret = {
      rekeyFile = ../../secrets/master/outline-oidc-secret.age;
      owner = config.services.outline.user;
      group = config.services.outline.group;
    };
    kakao-api-key = {
      rekeyFile = ../../secrets/master/kakao-api-key.age;
      owner = config.services.nocodb.user;
      group = config.services.nocodb.group;
    };
    nc-api-token = {
      rekeyFile = ../../secrets/master/nc-api-token.age;
      owner = config.services.nocodb.user;
      group = config.services.nocodb.group;
    };
  };
}
