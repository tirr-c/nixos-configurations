{ config, lib, pkgs, ... }:

let
  inherit (lib) types;
  cfg = config.services.nocodb-webhooks;
  nocodbConfig = config.services.nocodb;
in

{
  options.services.nocodb-webhooks = {
    enable = lib.mkOption {
      type = types.bool;
      default = false;
    };

    package = lib.mkOption {
      type = types.package;
    };

    serveAddress = lib.mkOption {
      type = types.str;
      default = "tcp:0.0.0.0:8080";
    };

    kakaoApiKeyPath = lib.mkOption {
      type = types.externalPath;
      default = "/var/lib/nocodb-webhooks/kakao-api-key";
    };

    nocodb = {
      base = lib.mkOption {
        type = types.str;
        default = "_";
      };

      thumbnailField = lib.mkOption {
        type = types.str;
      };

      apiTokenPath = lib.mkOption {
        type = types.externalPath;
        default = "/var/lib/nocodb-webhooks/nc-api-token";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.nocodb-webhooks =
      let
        unitDeps = [config.systemd.services.nocodb.name];
      in
      {
        description = "Custom webhooks for NocoDB";

        after = ["network.target"] ++ unitDeps;
        requires = unitDeps;

        before = ["multi-user.target"];
        wantedBy = ["multi-user.target"];

        environment = lib.mkMerge [
          {
            DENO_SERVE_ADDRESS = cfg.serveAddress;
            NC_HOST = if nocodbConfig.publicUrl != null then nocodbConfig.publicUrl else "http://localhost:${builtins.toString nocodbConfig.port}";
            NC_BASE_ID = cfg.nocodb.base;
            NC_THUMBNAIL_FIELD_ID = cfg.nocodb.thumbnailField;
          }
        ];

        path = [pkgs.coreutils];

        script = ''
          export KAKAO_API_KEY=$(head -n1 ${lib.escapeShellArg cfg.kakaoApiKeyPath})
          export NC_API_TOKEN=$(head -n1 ${lib.escapeShellArg cfg.nocodb.apiTokenPath})
          exec ${lib.getExe cfg.package}
        '';

        serviceConfig = {
          User = nocodbConfig.user;
          Group = nocodbConfig.group;
          Restart = "always";
          ProtectSystem = "strict";
          PrivateTmp = true;
          UMask = "0007";

          StateDirectory = "nocodb-webhooks";
          StateDirectoryMode = "0750";
        };
      };
  };
}
