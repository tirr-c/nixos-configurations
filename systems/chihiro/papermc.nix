{ config, pkgs, lib, ... }:

let
  serverDirectory = config.users.users.papermc.home;
in

{
  nixpkgs.overlays = [
    (final: prev: {
      papermc = prev.papermc.overrideAttrs (finalAttrs: prevAttrs: {
        version = "1.21.5-58";
        hash = "sha256-dP8tXxAtLNFEwwssVpflwrMVNMLuvKJtVXa+SvGwbVU=";

        src =
          let
            version-split = lib.strings.splitString "-" finalAttrs.version;
            mcVersion = builtins.elemAt version-split 0;
            buildNum = builtins.elemAt version-split 1;
          in
          pkgs.fetchurl {
            url = "https://api.papermc.io/v2/projects/paper/versions/${mcVersion}/builds/${buildNum}/downloads/paper-${mcVersion}-${buildNum}.jar";
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
