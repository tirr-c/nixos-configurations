{ inputs, config, pkgs, ... }:

{
  imports = [
    inputs.agenix.nixosModules.default
    inputs.agenix-rekey.nixosModules.default
  ];

  nixpkgs.overlays = [
    inputs.agenix-rekey.overlays.default
  ];

  environment.systemPackages = with pkgs; [
    age
    agenix-rekey
  ];

  age.rekey = {
    masterIdentities = [
      {
        identity = ./master.age;
        pubkey = ./master.pub;
      }
    ];
    storageMode = "local";
    localStorageDir = "${inputs.self.outPath}/secrets/rekeyed/${config.networking.hostName}";
  };
}
