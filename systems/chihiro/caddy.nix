{ ... }:

{
  services.caddy = {
    enable = true;
    openFirewall = true;
    email = "retica@tirr.dev";

    globalConfig = ''
      skip_install_trust
    '';
  };
}
