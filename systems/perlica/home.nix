{
  imports = [
    ../../users/tirr/minimal.nix
  ];

  programs.ssh.enable = true;
  programs.ssh.enableDefaultConfig = false;
}
