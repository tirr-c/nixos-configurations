{ inputs, ... }:

{
  imports = [
    inputs.self.lib.homeModules.tirr-minimal
  ];

  programs.ssh.enable = true;
  programs.ssh.enableDefaultConfig = false;
}
