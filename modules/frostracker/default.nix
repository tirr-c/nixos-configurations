{ config, lib, pkgs, ... }:

let
  inherit (lib) types;
  cfg = config.services.frostracker;
in

{
  options.services.frostracker = {
    enable = lib.mkOption {
      type = types.bool;
      default = false;
    };

    package = lib.mkOption {
      type = types.package;
      default = pkgs.frostracker;
    };

    port = lib.mkOption {
      type = types.port;
      default = 53972;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.frostracker = {
      description = "Frosthaven Tracker";
      wantedBy = ["multi-user.target"];
      after = ["network.target"];

      environment = {
        PORT = "${builtins.toString cfg.port}";
      };

      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package}";
        Restart = "on-failure";
        DynamicUser = true;
      };
    };
  };
}
