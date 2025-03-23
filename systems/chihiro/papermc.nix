{ config, pkgs, lib, ... }:

let
  serverDirectory = config.users.users.papermc.home;
in

{
  nixpkgs.overlays = [
    (final: prev: {
      papermc = prev.papermc.overrideAttrs (finalAttrs: prevAttrs: {
        version = "1.21.4-214";
        hash = "sha256-qwMNaJAPO4/weoR4PSj1s9imx6JL7vD8t3ABHd8EWkA=";

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
  services.caddy.virtualHosts = {
    ":8123" = {
      extraConfig = ''
        root * ${serverDirectory}/plugins/dynmap/web
      '';
    };
  };
}
