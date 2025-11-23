{ ... }:

{
  services.zrepl = {
    enable = true;
    settings = {
      jobs = [
        {
          type = "sink";
          name = "backup";
          root_fs = "veritas/backups";
          serve = {
            type = "tcp";
            listen = ":39401";
            listen_freebind = true;
            clients = {
              "100.64.0.0/24" = "tailscale-*";
            };
          };

          recv = {
            properties.override = {
              mountpoint = "none";
              canmount = "off";
              "org.openzfs.systemd:ignore" = "on";
            };

            # Encrypted send mode
            placeholder.encryption = "off";

            bandwidth_limit.max = "50MiB";
          };
        }
      ];
    };
  };
}
