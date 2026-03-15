{ ... }:

let
  nodeList = [
    "plachta.tirr.local:9100"
    "xaihi.tirr.local:9100"
  ];
in

{
  services.prometheus = {
    enable = true;
    globalConfigs.scrape_interval = "15s";
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          { targets = nodeList; }
        ];
      }
    ];
  };

  services.prometheus.exporters.node = {
    enable = true;
    openFirewall = true;
    enabledCollectors = ["systemd"];
  };
}
