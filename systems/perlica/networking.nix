{ lib, config, ... }:

let
  bridgeName = "br-lan";
  wlanDevName = "wlan0";
  uplinkDevName = "enp1s0";
  publicIp = "210.121.177.250";
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
    enable = true;

    radios.${wlanDevName} = {
      band = "2g";
      countryCode = "KR";

      wifi4.capabilities = lib.mkForce [
        "HT40"
        "SHORT-GI-20"
      ];

      networks.${wlanDevName} = {
        ssid = "Lunaere";
        authentication = {
          mode = "wpa2-sha1";
          wpaPasswordFile = config.age.secrets.wpaPassword.path;
        };
        settings = {
          bridge = bridgeName;
        };
      };
    };
  };

  boot.kernelModules = ["cfg80211" "brcmfmac"];
  boot.extraModprobeConfig = lib.mkAfter ''
    options cfg80211 power_save=0
    options brcmfmac roamoff=1 feature_disable=0x82000
  '';

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
        "/lunaere.${localDomain}/10.48.0.2"
      ];
      dhcp-host = [
        "d8:5e:d3:8e:79:6a,10.48.0.2,lunaere"
        "bc:24:11:5f:7a:bd,10.48.0.3,plachta"
        "bc:24:11:47:43:7b,10.48.0.4,xaihi"
        "bc:24:11:fd:4c:4b,10.48.0.5,yvonne"
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
        destination = "10.48.0.4:80";
        loopbackIPs = [publicIp];
      }
      {
        sourcePort = 443;
        proto = "tcp";
        destination = "10.48.0.4:443";
        loopbackIPs = [publicIp];
      }
      {
        sourcePort = 8448;
        proto = "tcp";
        destination = "10.48.0.4:8448";
        loopbackIPs = [publicIp];
      }
      {
        sourcePort = 56881;
        proto = "tcp";
        destination = "10.48.0.5:56881";
      }
      {
        sourcePort = "50000:51000";
        proto = "udp";
        destination = "10.48.0.5:50000-51000";
      }
    ];
  };

  networking.firewall = {
    enable = true;

    trustedInterfaces = [bridgeName];
    logRefusedConnections = false;
  };
}
