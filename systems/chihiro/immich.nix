{ ... }:

{
  services.immich = {
    enable = true;

    host = "0.0.0.0";
    port = 54080;
    openFirewall = true;

    mediaLocation = "/srv/chihiro/photos";
    accelerationDevices = ["/dev/dri/renderD128"];
    settings = {
      server.externalDomain = "https://photos.veritas.tirr.network";
    };
  };
}
