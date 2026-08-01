{ lib, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/virtualisation/amazon-image.nix"
  ];

  ec2.efi = true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
