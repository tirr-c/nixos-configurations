{ config, ... }:

let
  bridgeName = "br-lan";
  wlanDevName = "wlan0";
  uplinkDevName = "uplink";
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

    links = {
      "10-${uplinkDevName}" = {
        enable = true;
        matchConfig.MACAddress = "c8:a3:62:e4:3e:bf";
        linkConfig.Name = uplinkDevName;
      };
    };

    networks = {
      "20-onboard-bridge" = {
        matchConfig.Name = "end0";
        bridge = [bridgeName];

        linkConfig.RequiredForOnline = "no";
      };

      "20-wlan-unmanaged" = {
        matchConfig.Name = "wlan0";
        linkConfig.Unmanaged = "yes";
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
    # FIXME: Re-enable when I have better wireless card
    enable = false;

    radios.${wlanDevName} = {
      band = "5g";
      countryCode = "KR";

      networks.${wlanDevName} = {
        ssid = "Lunaere";
        authentication = {
          mode = "wpa3-sae";
          saePasswordsFile = config.age.secrets.saePasswords.path;
        };
        settings = {
          bridge = bridgeName;
        };
      };
    };
  };

  systemd.services.hostapd.requires = ["network-online.target"];
  systemd.services.hostapd.after = ["network-online.target"];

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

  systemd.services.unbound.requires = ["network-online.target"];
  systemd.services.unbound.after = ["network-online.target"];

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

      address = [
        "/${config.networking.hostName}/10.48.0.1"
      ];
      dhcp-host = [
        "d8:5e:d3:8e:79:6a,10.48.0.2,lunaere"
      ];

      dhcp-option = [
        "3,0.0.0.0"
        "6,0.0.0.0"
        "option:domain-search,${localDomain}"
      ];
    };
  };

  systemd.services.dnsmasq.requires = ["network-online.target"];
  systemd.services.dnsmasq.after = ["network-online.target"];

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
    logRefusedConnections = false;
  };
}
