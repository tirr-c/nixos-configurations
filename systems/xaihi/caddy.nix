{ ... }:

{
  services.caddy = {
    enable = true;
    email = "retica@tirr.dev";
  };

  networking.firewall = {
    allowedTCPPorts = [80 443];
    allowedUDPPorts = [443];
  };
}
