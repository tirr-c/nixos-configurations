{ config, ... }:

{
  imports = [
    ../../secrets
  ];

  age.identityPaths = ["/etc/agenix-host-key"];
  age.rekey.hostPubkey = ./host-pubkey.pub;

  age.secrets = {
    "cloudflare-token-tirr.network".rekeyFile = ../../secrets/master/cloudflare-token/tirr.network.age;
    headscale-oidc-client-secret = {
      rekeyFile = ../../secrets/master/headscale-oidc-client-secret.age;
      owner = config.services.headscale.user;
      group = config.services.headscale.group;
    };
  };
}
