{ config, pkgs, lib, ... }:

let
  serverDirectory = config.users.users.papermc.home;
in

{
  nixpkgs.overlays = [
    (final: prev: {
      papermc = prev.papermc.overrideAttrs (finalAttrs: prevAttrs: {
        version = "1.21.10-115";
        hash = "sha256-1fR/Y5OqZHdZ8QHwIjH6ggDlvM02CBo+6Lal/ZZzkFc=";

        src = pkgs.fetchurl {
          url = "https://fill-data.papermc.io/v1/objects/d5f47f6393aa647759f101f02231fa8200e5bccd36081a3ee8b6a5fd96739057/paper-1.21.10-115.jar";
          inherit (finalAttrs) hash;
        };
      });
    })
  ];

  systemd.sockets.papermc = {
    partOf = [config.systemd.services.papermc.name];
    socketConfig = {
      ListenFIFO = "%t/papermc.stdin";
    };
  };

  systemd.services.papermc = {
    description = "PaperMC server";

    serviceConfig = {
      Type = "simple";
      WorkingDirectory = serverDirectory;
      ExecStart = ''${lib.getExe pkgs.papermc} -XX:+UseZGC -XX:SoftMaxHeapSize=16G -Xmx28G'';
      KillSignal = "SIGINT";
      SuccessExitStatus = "130";
      User = "papermc";
      Group = "papermc";
      Restart = "on-failure";
      Sockets = config.systemd.sockets.papermc.name;
      StandardInput = "socket";
      StandardOutput = "journal";
      StandardError = "journal";
    };

    wantedBy = ["multi-user.target"];
    after = ["network.target"];
  };

  services.caddy.enable = true;

  services.caddy.globalConfig = ''
    skip_install_trust
  '';

  # Bluemap
  services.caddy.virtualHosts."https://100.64.0.3:8100" = {
    extraConfig = ''
      tls internal

      root * ${serverDirectory}/bluemap/web

      file_server

      @tiles path_regexp ^/maps/[^/]+/tiles/
      reverse_proxy @tiles localhost:58100 {
        @ok status 200
        @empty status 204
        handle_response @ok {
          header >cache-control "max-age=30, must-revalidate"
        }
        handle_response @empty {
          header >cache-control "no-store"
        }
      }

      @live path_regexp ^/maps/[^/]+/tiles/
      header @live ?cache-control "no-store"
      reverse_proxy /maps/* localhost:58100
    '';
  };
}
