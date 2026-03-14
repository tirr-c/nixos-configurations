{ ... }:

{
  users.users.tirr = {
    isNormalUser = true;
    description = "Wonwoo Choi";
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keyFiles = [../../users/tirr/authorized_keys];
  };
}
