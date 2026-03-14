{ pkgs, ... }:

{
  users.users.tirr = {
    isNormalUser = true;
    description = "Wonwoo Choi";
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keyFiles = [../../users/tirr/authorized_keys];
  };

  users.users.tirrsmb = {
    isSystemUser = true;
    group = "users";
    home = "/srv/data/home";
    shell = pkgs.bashInteractive;
    uid = 1001;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGxX2SLoEr3NTqiMf+nWmlprqZa6lFfrOSiGhSXdk0+N"
    ];
  };
}
