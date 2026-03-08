{ ... }:

{
  imports = [
    ../../secrets
  ];

  age.identityPaths = ["/etc/agenix-host-key"];
  age.rekey.hostPubkey = ./host-pubkey.pub;

  age.secrets = {
    wpaPassword.rekeyFile = ../../secrets/master/lunaere-wpa.age;
    saePasswords.rekeyFile = ../../secrets/master/lunaere-sae.age;
  };
}
