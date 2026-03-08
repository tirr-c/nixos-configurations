{ config, ... }:

let
  bridgeName = "br-lan";
  wlanDevName = "wlan0";
  uplinkDevName = "enp1s0u1c2";
  publicIp = "222.112.63.131";
  localDomain = "tirr.local";
in

{
  networking.useNetworkd = true;

  systemd.network = {
    enable = true;

    netdevs = {
      "10-${bridgeName}" = {
        enable = true;
        netdevConfig = {
          Name = bridgeName;
          Kind = "bridge";
        };
      };
    };

    networks = {
      "20-onboard-bridge" = {
        matchConfig.Name = "end0";
        bridge = [bridgeName];

        linkConfig.RequiredForOnline = "no";
      };

      "50-bridge" = {
        matchConfig.Name = bridgeName;
        DHCP = "no";
        address = ["10.48.0.1/24"];
        dns = ["127.0.0.1"];
        domains = ["~${localDomain}"];

        linkConfig.RequiredForOnline = "yes";
      };

      "50-uplink" = {
        matchConfig.Name = uplinkDevName;
        DHCP = "yes";
        dns = ["127.0.0.1"];

        dhcpV4Config = {
          UseDNS = "no";
          SendRelease = "no";
        };

        dhcpV6Config = {
          UseDNS = "no";
          SendRelease = "no";
        };
      };
    };
  };

  services.hostapd = {
    enable = true;

    radios.${wlanDevName} = {
      band = "2g";
      countryCode = "KR";

      networks.${wlanDevName} = {
        ssid = "Lunaere";
        authentication = {
          mode = "wpa3-sae-transition";

          wpaPasswordFile = config.age.secrets.wpaPassword.path;
          saePasswordsFile = config.age.secrets.saePasswords.path;
        };
        settings = {
          bridge = bridgeName;
        };
      };
    };
  };

  services.unbound = {
    enable = true;
    resolveLocalQueries = false;
    settings = {
      server = {
        interface = ["127.0.0.1" "10.48.0.1"];
        access-control = [
          "127.0.0.1 allow"
          "10.48.0.0/24 allow"
        ];
        prefetch = true;

        do-not-query-localhost = false;
        domain-insecure = ["${localDomain}."];
        local-zone = [
          ''"${localDomain}." nodefault''
        ];
      };
      stub-zone = [
        {
          name = "${localDomain}.";
          stub-addr = [
            "127.0.0.1@5353"
          ];
          stub-no-cache = true;
        }
      ];
      forward-zone = [
        {
          name = ".";
          forward-addr = [
            "1.1.1.1@853#cloudflare-dns.com"
            "1.0.0.1@853#cloudflare-dns.com"
          ];
          forward-tls-upstream = true;
        }
      ];
    };
  };

  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    settings = {
      interface = bridgeName;
      port = 5353;
      bind-interfaces = true;

      domain-needed = true;
      bogus-priv = true;

      no-resolv = true;
      no-hosts = true;

      domain = localDomain;
      expand-hosts = true;
      dhcp-range = "10.48.0.100,10.48.0.254";

      dhcp-host = [
        "d8:5e:d3:8e:79:6a,10.48.0.2,lunaere"
      ];

      dhcp-option = [
        "option:domain-search,${localDomain}"
      ];
    };
  };

  networking.nftables.enable = true;

  networking.nat = {
    enable = true;
    internalInterfaces = [bridgeName];
    externalInterface = uplinkDevName;
    forwardPorts = [
      {
        sourcePort = 80;
        proto = "tcp";
        destination = "10.48.0.2:80";
        loopbackIPs = [publicIp];
      }
      {
        sourcePort = 443;
        proto = "tcp";
        destination = "10.48.0.2:443";
        loopbackIPs = [publicIp];
      }
      {
        sourcePort = 8448;
        proto = "tcp";
        destination = "10.48.0.2:8448";
        loopbackIPs = [publicIp];
      }
    ];
  };

  networking.firewall = {
    enable = true;

    trustedInterfaces = [bridgeName];
  };
}
