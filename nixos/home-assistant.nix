{ config, libs, pkgs, modulesPath, ... }:

let 
  unstable = import <nixos-unstable> {};
in
{
  nixpkgs.overlays = [
    (self: super: {
      inherit (unstable) home-assistant;
    })
  ];

  disabledModules = [
    "services/home-automation/home-assistant.nix"
  ];

  imports = [
    <nixos-unstable/nixos/modules/services/home-automation/home-assistant.nix>
  ];
  
  services.home-assistant = {
    enable = true;
    extraComponents = [
      # Components required to complete the onboarding
      "analytics"
      "google_translate"
      "met"
      "radio_browser"
      "shopping_list"
      # Recommended for fast zlib compression
      # https://www.home-assistant.io/integrations/isal
      "isal"
      "mqtt"
      "plex"
      "braviatv"
      "roku"
      "unifi"
      "generic_thermostat"
    ];
    config = {
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = {};
      homeassistant = {
        unit_system = "metric";
      };
      http = {
        server_host = "::1";
        trusted_proxies = [ "::1" ];
        use_x_forwarded_for = true;
      };
    };
  };

  services.mosquitto = {
    enable = true;
    listeners = [
      {
        acl = [ "pattern readwrite #" ];
        omitPasswordAuth = true;
        settings.allow_anonymous = true;
      }
    ];
  };

  services.zigbee2mqtt = {
    enable = true;
    settings = {
      homeassistant = true;
      permit_join = true;
      mqtt = {
        base_topic = "zigbee2mqtt";
        server = "mqtt://127.0.0.1:1883";
      };
      serial = {
        port = "/dev/ttyUSB0";
        adapter = "ember";
      };
      frontend = {
        enabled = true;
        port = 18080;
        host = "0.0.0.0";
      };
    };
  };

#  networking.firewall.allowedTCPPorts = [ 18080 ];

  services.nginx.virtualHosts."home.ush.bouncr.xyz" = {
    extraConfig = ''
        proxy_buffering off;
      '';
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://[::1]:8123";
      proxyWebsockets = true;
    };
  };
}
