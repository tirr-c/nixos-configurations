{ pkgs, ... }:

let
  out-of-your-element = pkgs.callPackage ../../packages/out-of-your-element {};
in

{
  services.matrix-continuwuity = {
    enable = true;

    settings.global = {
      address = ["127.0.0.1"];
      server_name = "matrix.tirr.dev";

      database_backup_path = "/var/lib/continuwuity/backups";
      new_user_displayname_suffix = "";
      ip_lookup_strategy = 1;
      max_request_size = 50000000;
      allow_registration = false;
      require_auth_for_profile_requests = true;
      rocksdb_optimize_for_spinning_disks = false;

      well_known = {
        client = "https://matrix.tirr.dev";
        server = "matrix.tirr.dev:443";
        support_mxid = "@tirr:matrix.tirr.dev";
      };
    };
  };

  services.out-of-your-element = {
    enable = true;
    package = out-of-your-element;
  };

  services.caddy.virtualHosts = {
    "matrix.tirr.dev" = {
      serverAliases = ["matrix.tirr.dev:8448"];

      extraConfig = ''
        reverse_proxy /_matrix/* localhost:6167
        reverse_proxy /_conduwuit/* localhost:6167
        reverse_proxy /_continuwuity/* localhost:6167
        reverse_proxy /.well-known/matrix/* localhost:6167
      '';
    };

    "bridge.matrix.tirr.dev" = {
      extraConfig = ''
        reverse_proxy localhost:6693
      '';
    };
  };

  systemd.services.ooye.after = ["continuwuity.service" "caddy.service"];

  networking.firewall.allowedTCPPorts = [8448];
}
