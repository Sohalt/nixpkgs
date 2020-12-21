{ config, lib, pkgs,  ... }:

with lib;
let
  cfg = config.services.maloja;

  format = pkgs.formats.ini {};

  dataDir = "/var/lib/maloja";

  fqdn =
      let
        join = hostName: domain: hostName + optionalString (domain != null) ".${domain}";
      in join config.networking.hostName config.networking.domain;

  malojaConfFile = format.generate "settings.ini" cfg.settings;
  replaceSecret = secretFile: placeholder: targetFile: optionalString (secretFile != null) ''${pkgs.replace}/bin/replace-literal -ef ${placeholder} "$(cat ${secretFile})" ${targetFile}'';
  populateSecrets = pkgs.writeShellScript "maloja-pre-start" ''
  install -Dm 700 "${malojaConfFile}" "${dataDir}/settings/settings.ini"
  ${replaceSecret cfg.lastfm.apiKeyFile "@@LASTFM_API_KEY@@" "${dataDir}/settings/settings.ini"}
  ${replaceSecret cfg.lastfm.apiSecretFile "@@LASTFM_API_SECRET@@" "${dataDir}/settings/settings.ini"}
  ${replaceSecret cfg.fanarttv.apiKeyFile "@@FANARTTV_API_KEY@@" "${dataDir}/settings/settings.ini"}
  ${replaceSecret cfg.spotify.apiIdFile "@@SPOTIFY_API_ID@@" "${dataDir}/settings/settings.ini"}
  ${replaceSecret cfg.spotify.apiSecretFile "@@SPOTIFY_API_SECRET@@" "${dataDir}/settings/settings.ini"}
  ${replaceSecret cfg.thumbor.secretFile "@@THUMBOR_SECRET@@" "${dataDir}/settings/settings.ini"}
  '';


 in {

  ###### interface

  options = {

    services.maloja = {

      enable = mkEnableOption "maloja";

      passwordFile = mkOption {
        type = types.nullOr types.str;
        description = "A file containing the admin password";
      };

      listenAddress = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "Address where maloja will listen";
      };
      port = mkOption {
        type = types.port;
        default = 42010;
        description = "Port where maloja will listen";
      };

      lastfm = {
        scrobble = mkEnableOption "scrobble to last.fm";
        apiKeyFile = mkOption {
          default = null;
          type = types.nullOr types.str;
          description = "File with api key for lastfm";
        };
        apiSecretFile = mkOption {
          default = null;
          type = types.nullOr types.str;
          description = "File with api secret for lastfm";
        };
      };
      fanarttv = {
      apiKeyFile = mkOption {
        default = null;
        type = types.nullOr types.str;
        description = "File with api key for fanart.tv";
      };
      };
      spotify = {
        apiIdFile = mkOption {
          default = null;
          type = types.nullOr types.str;
          description = "File with api id for spotify";
        };
        apiSecretFile = mkOption {
          default = null;
          type = types.nullOr types.str;
          description = "File with api secret for spotify";
        };
      };
      thumbor = {
        secretFile = mkOption {
          default = null;
          type = types.nullOr types.str;
          description = "File with sceret for thumbor server";
        };
      };

      settings = mkOption {
        type = format.type;
        description = "Maloja configuration. Refer to <link xlink:href="https://github.com/krateng/maloja/blob/master/settings.md"/> for details.";
      };

      nginx = mkOption {
        type = types.nullOr (types.submodule (
          recursiveUpdate
            (import ../web-servers/nginx/vhost-options.nix { inherit config lib; })
            {
              # enable encryption by default,
              # as sensitive admin login should not be transmitted in clear text.
              options.forceSSL.default = true;
              options.enableACME.default = true;
              options.locations.default = {
                "/" = {
                proxyPass = "http://${cfg.listenAddress}:${toString cfg.port}";
                };
              };
            }
          )
        );
        default = null;
        example = {
          serverAliases = [
            "maloaj.\${fqdn}"
            "musicstats.\${fdqn}"
          ];
          enableACME = false;
        };
        description = ''
            With this option, you can customize an nginx virtualHost which already has sensible defaults for Maloja.
            Set this to {} to just enable the virtualHost if you don't need any customization.
            If enabled, then by default, the <option>serverName</option> is
            <literal>maloja.${config.networking.hostName}.''${config.networking.domain}</literal>,
            SSL is active, and certificates are acquired via ACME.
            If this is set to null (the default), no nginx virtualHost will be configured.
        '';
      };
    };
  };


  ###### implementation

  config = mkIf cfg.enable {
    services.maloja.settings = {
      HTTP = {
    WEB_PORT = cfg.port;
    HOST = cfg.listenAddress;
      };
      "Third Party Services" = {
    SCROBBLE_LASTFM = cfg.lastfm.scrobble;

    LASTFM_API_KEY = mkIf (cfg.lastfm.apiKeyFile != null) "@@LASTFM_API_KEY@@";
    LASTFM_API_SECRET = mkIf (cfg.lastfm.apiSecretFile != null) "@@LASTFM_API_SECRET@@";

    FANARTTV_API_KEY = mkIf (cfg.fanarttv.apiKeyFile != null) "@@FANARTTV_API_KEY@@";

    SPOTIFY_API_ID = mkIf (cfg.spotify.apiIdFile != null) "@@SPOTIFY_API_ID@@";
    SPOTIFY_API_SECRET = mkIf (cfg.spotify.apiSecretFile != null) "@@SPOTIFY_API_SECRET@@";

    THUMBOR_SECRET = mkIf (cfg.thumbor.secretFile != null) "@@THUMBOR_SECRET@@";
      };
    };

    systemd.services.maloja = {
        description = "Maloja Server";
        serviceConfig = {
          DynamicUser = true;
          Environment = [ "MALOJA_SKIP_SETUP=true" "MALOJA_DATA_DIRECTORY=${dataDir}" ];
          StateDirectory = "maloja";
          ExecStartPre = populateSecrets;
          ExecStart = "${pkgs.maloja}/bin/maloja run";
        };

        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
    };

    services.nginx.virtualHosts = mkIf (cfg.nginx != null) {
      "maloja.${fqdn}" = cfg.nginx;
    };
  };
}
