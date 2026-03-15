{ ... }:

{
  services.zrepl = {
    enable = true;
    settings = {
      global.monitoring = [
        {
          type = "prometheus";
          listen = ":9811";
          listen_freebind = true;
        }
      ];

      jobs = [
        {
          type = "push";
          name = "backup";
          connect = {
            type = "tcp";
            address = "100.64.0.3:39401";
          };

          filesystems = {
            "plachta/data/conduwuit" = true;
            "plachta/data/music" = true;
            "plachta/data/photos" = true;
            "plachta/data/vault" = true;
            "plachta/data/youtube" = true;
          };

          send.encrypted = true;

          snapshotting = {
            type = "periodic";
            prefix = "zrepl-";
            interval = "1d";
          };

          pruning = {
            keep_sender = [
              { type = "not_replicated"; }
              {
                type = "grid";
                grid = "7x1d | 3x7d | 2x30d";
                regex = "^zrepl-.*";
              }
            ];

            keep_receiver = [
              {
                type = "grid";
                grid = "7x1d | 3x7d | 2x30d";
                regex = "^zrepl-.*";
              }
            ];
          };
        }
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [9811];
}
