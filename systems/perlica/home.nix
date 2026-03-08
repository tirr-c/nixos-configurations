{ inputs, lib, ... }:

{
  imports = [
    inputs.self.lib.homeModules.tirr
  ];

  programs.ssh.enable = true;
  programs.ssh.enableDefaultConfig = false;

  programs.awscli.enable = lib.mkForce false;
}
