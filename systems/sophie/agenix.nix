{ lib, inputs, ... }:

{
  imports = [
    ../../secrets
  ];

  age.rekey.localStorageDir = lib.mkForce "${inputs.self.outPath}/secrets/rekeyed/sophie";

  age.identityPaths = ["/etc/agenix-host-key"];
  age.rekey.hostPubkey = ./host-pubkey.pub;

  age.secrets = {
    "cloudflare-token-mitir.social".rekeyFile = ../../secrets/master/cloudflare-token/mitir.social.age;
  };
}
