{ ... }:

{
  services.calibre-server = {
    enable = true;
    port = 58383;
    libraries = [
      "/srv/chihiro/calibre/library"
    ];
    auth = {
      enable = true;
      mode = "basic";
      userDb = "/srv/chihiro/calibre/users.sqlite";
    };
  };

  services.caddy.virtualHosts."https://100.64.0.3:8383" = {
    extraConfig = ''
      tls internal
      reverse_proxy localhost:58383
    '';
  };
}
