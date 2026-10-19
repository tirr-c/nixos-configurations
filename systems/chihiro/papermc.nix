{ config, pkgs, lib, ... }:

let
  serverDirectory = config.users.users.papermc.home;
in

{
  nixpkgs.overlays = [
    (final: prev: (
      let
        replaceJre = builtins.replaceStrings [(lib.getExe prev.jre)] [(lib.getExe prev.openjdk25)];
        hashBase16 = "4208a692538104ec88699c0e078b2b89842920a10472ebb37e72cdda27c0d80e";
      in
      {
        papermc = prev.papermc.overrideAttrs (finalAttrs: prevAttrs: rec {
          version = "26.3-206";
          hash = builtins.convertHash {
            hash = hashBase16;
            hashAlgo = "sha256";
            toHashFormat = "sri";
          };

          src = pkgs.fetchurl {
            url = "https://fill-data.papermc.io/v1/objects/${hashBase16}/paper-${version}.jar";
            inherit hash;
          };

          installPhase = replaceJre prevAttrs.installPhase;
        });
      }
    ))
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
