{ config, lib, pkgs, ... }:

let
  inherit (lib) types;
  cfg = config.services.out-of-your-element;
  defaultUser = "ooye";
  defaultGroup = "ooye";
in

{
  options.services.out-of-your-element = {
    enable = lib.mkOption {
      type = types.bool;
      default = false;
    };

    package = lib.mkOption {
      type = types.package;
      default = pkgs.out-of-your-element;
    };

    user = lib.mkOption {
      type = types.str;
      default = defaultUser;
    };

    group = lib.mkOption {
      type = types.str;
      default = defaultUser;
    };
  };

  config = lib.mkIf cfg.enable {
    users.users = lib.optionalAttrs (cfg.user == defaultUser) {
      ${defaultUser} = {
        isSystemUser = true;
        group = cfg.group;
        home = "/var/lib/ooye";
      };
    };

    users.groups = lib.optionalAttrs (cfg.group == defaultGroup) {
      ${defaultGroup} = { };
    };

    systemd.services.ooye = {
      description = "Out Of Your Element";

      after = ["network.target"];

      before = ["multi-user.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        Restart = "always";
        ProtectSystem = "strict";
        PrivateTmp = true;
        UMask = "0077";

        WorkingDirectory = "/var/lib/ooye";
        ExecStart = "${lib.getExe cfg.package} start";

        StateDirectory = "ooye";
        StateDirectoryMode = "0700";
        RuntimeDirectory = "ooye";
        RuntimeDirectoryMode = "0700";
        CacheDirectory = "ooye";
        CacheDirectoryMode = "0700";
      };
    };
  };
}
