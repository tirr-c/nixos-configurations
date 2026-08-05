{ config, inputs, ... }:

let
  misskey = inputs.misskey.packages.${config.nixpkgs.hostPlatform.system}.misskey;
in

{
  systemd.services.misskey = {
    after = [
      "network-online.target"
      "postgresql.target"
    ];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      ExecStart = "${misskey}/bin/misskey-server ${./config.json}";
      RuntimeDirectory = "misskey";
      RuntimeDirectoryMode = "700";
      StateDirectory = "misskey";
      StateDirectoryMode = "700";
      TimeoutSec = 60;
      DynamicUser = true;
      User = "misskey";
      LockPersonality = true;
      PrivateDevices = true;
      PrivateUsers = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectProc = "invisible";
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      RestrictAddressFamilies = "AF_INET AF_INET6 AF_UNIX AF_NETLINK";
    };
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = ["misskey"];
    ensureUsers = [
      {
        name = "misskey";
        ensureDBOwnership = true;
      }
    ];
    extensions = ps: with ps; [pgroonga];
  };

  services.redis.servers = {
    misskey = {
      enable = true;
      port = 6379;
    };
  };

  services.caddy = {
    enable = true;
    virtualHosts."mitir.social" = {
      useACMEHost = "mitir.social";
      extraConfig = ''
        reverse_proxy localhost:3000
      '';
    };
  };

  security.acme.acceptTerms = true;
  security.acme.certs."mitir.social" = {
    email = "retica@tirr.dev";

    dnsProvider = "cloudflare";
    credentialFiles = {
      CF_DNS_API_TOKEN_FILE = config.age.secrets."cloudflare-token-mitir.social".path;
    };
  };
}
