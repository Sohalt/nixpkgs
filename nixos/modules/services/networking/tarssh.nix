{ config, lib, pkgs, ... }:

with lib;

let
  cfg  = config.services.tarssh;
in

{
  ###### interface

  options = {

    services.tarssh = {

      enable = mkEnableOption "Whether to enable the tarssh ssh tarpit";

      listenAddress = mkOption {
        type = types.str;
        default = "0.0.0.0";
        description = ''
          Host, IPv4 or IPv6 address to listen to.
        '';
      };

      port = mkOption {
        type = types.port;
        default = 22;
        description = ''
          Specifies on which port tarssh listens.
        '';
      };

      openFirewall = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to automatically open the specified ports in the firewall.
        '';
      };
    };
  };


  ###### implementation

  config = mkIf cfg.enable {

    networking.firewall.allowedTCPPorts = optional cfg.openFirewall cfg.port;

    systemd.services.tarssh = {
      description = "tarssh";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        DynamicUser = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        MemoryDenyWriteExecute = true;
        ProtectClock = true;
        RestrictRealtime = true;
        PrivateDevices = true;
        ProtectHostname = true;
        AmbientCapabilities = mkIf (cfg.port < 1024) [ "CAP_NET_BIND_SERVICE" ];
        ExecStart = "${pkgs.tarssh}/bin/tarssh -l ${cfg.listenAddress}:${toString cfg.port}";
      };
    };
  };
}
