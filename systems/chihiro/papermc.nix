{ config, pkgs, lib, ... }:

let
  serverDirectory = config.users.users.papermc.home;
in

{
  nixpkgs.overlays = [
    (final: prev: (
      let
        replaceJre = builtins.replaceStrings [(lib.getExe prev.jre)] [(lib.getExe prev.openjdk25)];
      in
      {
        papermc = prev.papermc.overrideAttrs (finalAttrs: prevAttrs: {
          version = "26.1.2-60";
          hash = "sha256-agOzZdZsaK0NT+hDxRGD182/sg+j0RskI5hGSPS8nlc=";

          src = pkgs.fetchurl {
            url = "https://fill-data.papermc.io/v1/objects/6a03b365d66c68ad0d4fe843c51183d7cdbfb20fa3d11b2423984648f4bc9e57/paper-26.1.2-60.jar";
            inherit (finalAttrs) hash;
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
