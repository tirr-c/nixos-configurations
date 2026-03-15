{ ... }:

let
  nodeList = [
    "perlica.tirr.local:9100"
    "lunaere.tirr.local:9100"
    "plachta.tirr.local:9100"
    "xaihi.tirr.local:9100"
  ];
in

{
  services.prometheus = {
    enable = true;
    globalConfig.scrape_interval = "15s";
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          { targets = nodeList; }
        ];
      }
      {
        job_name = "zrepl";
        static_configs = [
          { targets = ["plachta.tirr.local:9811"]; }
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
