{ ... }:

{
  imports = [
    ../../secrets
  ];

  age.identityPaths = ["/etc/agenix-host-key"];
  age.rekey.hostPubkey = ./host-pubkey.pub;

  age.secrets = {
    nix-store-private-key.rekeyFile = ../../secrets/master/herta-nix-store-private-key.age;
  };
}
