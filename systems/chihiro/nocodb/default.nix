{ config, pkgs, ... }:

let
  nocodb-bin = pkgs.callPackage ../../../packages/nocodb-bin {};
in

{
  imports = [
    ./webhooks
  ];

  services.nocodb = {
    enable = true;
    package = nocodb-bin;
    port = 59708;
    allowLocalHooks = true;
  };

  services.nocodb-webhooks = {
    enable = true;
    serveAddress = "tcp:0.0.0.0:54443";
    kakaoApiKeyPath = config.age.secrets.kakao-api-key.path;
    nocodb = {
      base = "pcvqhb4nukwy4f6";
      thumbnailField = "clk6rj1i44c3yjp";
      apiTokenPath = config.age.secrets.nc-api-token.path;
    };
  };
}
