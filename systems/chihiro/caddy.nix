{ ... }:

{
  services.caddy = {
    enable = true;
    email = "retica@tirr.dev";

    globalConfig = ''
      skip_install_trust
    '';
  };

  networking.firewall = {
    allowedTCPPorts = [80 443];
    allowedUDPPorts = [443];
  };
}
