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
  systemd.network.enable = true;

  networking.bridges.${bridgeName} = {
    interfaces = ["end0"];
  };
  networking.interfaces.${bridgeName} = {
    useDHCP = false;
    ipv4.addresses = [
      {
        address = "10.48.0.1";
        prefixLength = 24;
      }
    ];
  };
  networking.interfaces.${uplinkDevName} = {
    useDHCP = true;
  };

  systemd.network = {
    links = {
      "10-${uplinkDevName}" = {
        enable = true;
        matchConfig.MACAddress = "c8:a3:62:e4:3e:bf";
        linkConfig.Name = uplinkDevName;
      };
    };

    networks = {
      "40-end0" = {
        name = "end0";
        linkConfig.RequiredForOnline = "no";
      };

      "40-wlan0-unmanaged" = {
        name = "wlan0";
        linkConfig.Unmanaged = "yes";
      };

      "40-${bridgeName}" = {
        name = bridgeName;
        dns = ["127.0.0.1"];
        domains = ["~${localDomain}"];

        linkConfig.RequiredForOnline = "yes";
      };

      "40-${uplinkDevName}" = {
        name = uplinkDevName;
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

  systemd.services.hostapd.wants = ["systemd-networkd-wait-online@${bridgeName}.service"];
  systemd.services.hostapd.after = ["systemd-networkd-wait-online@${bridgeName}.service"];

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

  systemd.services.unbound.wants = ["systemd-networkd-wait-online@${bridgeName}.service"];
  systemd.services.unbound.after = ["systemd-networkd-wait-online@${bridgeName}.service"];

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
        "/${config.networking.hostName}.${localDomain}/10.48.0.1"
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

  systemd.services.dnsmasq.wants = ["systemd-networkd-wait-online@${bridgeName}.service"];
  systemd.services.dnsmasq.after = ["systemd-networkd-wait-online@${bridgeName}.service"];

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
