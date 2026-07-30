{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
let
  domain = "moppu.dev";
  netbirdDomain = "netbird.${domain}";
  netbirdUrl = "https://${netbirdDomain}";
  clientId = "netbird";
  enable = true;
  enableNginx = true;
  coturnPass = config.sops.secrets."lala/netbird/coturnPass".path;
  dataStoreKey = config.sops.secrets."lala/netbird/dataStoreKey".path;
  relaySecret = config.sops.secrets."lala/netbird/relaySecret".path;
  relaySecretEnv = config.sops.secrets."lala/netbird/relaySecretEnv".path;
in
{
  sops.secrets = {
    "lala/netbird/coturnPass" = { };
    "lala/netbird/dataStoreKey" = { };
    "lala/netbird/relaySecret" = { };
    "lala/netbird/relaySecretEnv" = { };
  };

  services.netbird.server = {
    inherit enable enableNginx;
    domain = netbirdDomain;

    coturn = {
      inherit enable;
      domain = netbirdDomain;
      passwordFile = coturnPass;
    };

    signal = {
      inherit enable enableNginx;
      domain = netbirdDomain;
    };

    dashboard = {
      inherit enable enableNginx;
      domain = netbirdDomain;
      # https://github.com/netbirdio/netbird/blob/b65ec8b68a6a1ab8aee162a7b9e5147c0375af68/infrastructure_files/getting-started.sh#L931
      settings = {
        AUTH_AUTHORITY = "${netbirdUrl}/oauth2";
        AUTH_CLIENT_ID = clientId;
        AUTH_AUDIENCE = clientId;
        AUTH_SUPPORTED_SCOPES = "openid profile email groups";
        NETBIRD_MGMT_API_ENDPOINT = netbirdUrl;
        NETBIRD_MGMT_GRPC_API_ENDPOINT = netbirdUrl;
      };
    };

    management = {
      inherit enable enableNginx;
      domain = netbirdDomain;
      turnDomain = netbirdDomain;
      oidcConfigEndpoint = "${netbirdUrl}/oauth2/.well-known/openid-configuration";
      settings = {
        Signal.URI = "${netbirdDomain}:443";
        HttpConfig.AuthAudience = clientId;
        IdpManagerConfig.CientConfig.ClientID = clientId;
        DeviceAuthorizationFlow.ProviderConfig = {
          Audience = clientId;
          ClientID = clientId;
        };
        PKCEAuthorizationFlow.ProviderConfig = {
          Audience = clientId;
          ClientID = clientId;
        };
        TURNConfig = {
          Secret._secret = coturnPass;
          CredentialsTTL = "12h";
          TimeBasedCredentials = false;
          Turns = [
            {
              Password._secret = coturnPass;
              proto = "udp";
              URI = "turn:${netbirdDomain}:3478";
              Username = "netbird";
            }
          ];
        };
        Relay = {
          Addresses = [ "rels://${netbirdDomain}:33080" ];
          CredentialsTTL = "24h";
          Secret._secret = relaySecret;
        };
        DataStoreEncryptionKey._secret = dataStoreKey;
      };
    };
  };

  security.acme.acceptTerms = true;
  services.nginx.virtualHosts."${netbirdDomain}" = {
    enableACME = true;
    forceSSL = true;
  };

  virtualisation.oci-containers.containers.netbird-relay = {
    image = "netbirdio/relay:latest";
    ports = [
      "33080:33080"
    ];
    volumes = [
      "/var/lib/acme/${netbirdDomain}/:/certs:ro"
    ];
    environment = {
      NB_LOG_LEVEL = "info";
      NB_LISTEN_ADDRESS = ":33080";
      NB_EXPOSED_ADDRESS = "rels://${netbirdDomain}:33080";
      NB_TLS_CERT_FILE = "/certs/fullchain.pem";
      NB_TLS_KEY_FILE = "/certs/key.pem";
    };
    environmentFiles = [
      relaySecretEnv
    ];
  };

  networking.firewall = {
    allowedTCPPorts = [
      80
      443
      3478
      10000
      33080
    ];
    allowedUDPPorts = [
      3478
      5349
      33080
    ];
    allowedUDPPortRanges = [
      {
        from = 40000;
        to = 40050;
      }
    ];
  };
}
