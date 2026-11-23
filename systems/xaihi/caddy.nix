{ ... }:

{
  services.caddy = {
    enable = true;
    openFirewall = true;
    email = "retica@tirr.dev";
  };

  services.caddy.virtualHosts."photos.tirr.dev" = {
    extraConfig = ''
      reverse_proxy plachta.tirr.local:54080
    '';
  };
}
