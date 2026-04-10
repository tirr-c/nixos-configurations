{ config, pkgs, ... }:

let
  frostracker = pkgs.callPackage ../../packages/frostracker {};
  port = config.services.frostracker.port;
in

{
  services.frostracker = {
    enable = true;
    package = frostracker;
  };

  services.caddy.virtualHosts."https://100.64.0.3:3972" = {
    extraConfig = ''
      tls internal
      reverse_proxy localhost:${builtins.toString port}
    '';
  };

  networking.firewall.allowedTCPPorts = [3972];
}
