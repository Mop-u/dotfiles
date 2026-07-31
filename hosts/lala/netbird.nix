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
  stateDir = "/var/lib/netbird-mgmt";
  dashboardPort = 1234;
  coturnPass = config.sops.secrets."lala/netbird/coturnPass".path;
  dataStoreKey = config.sops.secrets."lala/netbird/dataStoreKey".path;
  relaySecret = config.sops.secrets."lala/netbird/relaySecret".path;
  relaySecretEnv = config.sops.secrets."lala/netbird/relaySecretEnv".path;
  idpKey = config.sops.secrets."lala/netbird/idpKey".path;
in
{
  sops.secrets = {
    "lala/netbird/coturnPass".owner = config.users.users.turnserver.name;
    "lala/netbird/dataStoreKey" = { };
    "lala/netbird/relaySecret" = { };
    "lala/netbird/relaySecretEnv" = { };
    "lala/netbird/idpKey" = { };
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

  security.acme.acceptTerms = true;
  services.traefik = {
    enable = true;
    staticConfigOptions = {
      entryPoints = {
        web.address = ":80";
        websecure.address = ":443";
      };
      certificatesResolvers.letsencrypt.acme = {
        email = "moppu@pm.me";
        storage = "acme.json";
        httpChallenge.entryPoint = "web";
      };
      log.level = "INFO";
    };
    dynamicConfigOptions = {
      http = {
        routers = {
          netbird-dashboard = {
            rule = "Host(`${netbirdDomain}`)";
            entryPoints = "websecure";
            tls.certResolver = "letsencrypt";
            service = "netbird-dash";
            priority = 1;
          };
          netbird-grpc = {
            rule = "Host(`${netbirdDomain}`) && (PathPrefix(`/management.ManagementService/`) || PathPrefix(`/management.ProxyService/`))";
            entryPoints = "websecure";
            tls.certResolver = "letsencrypt";
            service = "netbird-grpc";
            priority = 100;
          };
          netbird-signal = {
            rule = "Host(`${netbirdDomain}`) && PathPrefix(`/signalexchange.SignalExchange/`)";
            entryPoints = "websecure";
            tls.certResolver = "letsencrypt";
            service = "netbird-grpc-signal";
            priority = 100;
          };
          netbird-backend = {
            rule = "Host(`${netbirdDomain}`) && (PathPrefix(`/relay`) || PathPrefix(`/ws-proxy/`) || PathPrefix(`/api`) || PathPrefix(`/oauth2`))";
            entryPoints = "websecure";
            tls.certResolver = "letsencrypt";
            service = "netbird-server";
            priority = 100;
          };
        };
        services = {
          netbird-dash.loadBalancer.servers = [
            { url = "http://localhost:${toString dashboardPort}"; }
          ];
          netbird-server.loadBalancer.servers = [
            { url = "http://localhost:${toString config.services.netbird.server.management.port}"; }
          ];
          netbird-grpc.loadBalancer.servers = [
            { url = "h2c://localhost:${toString config.services.netbird.server.management.port}"; }
          ];
          netbird-grpc-signal.loadBalancer.servers = [
            { url = "h2c://localhost:${toString config.services.netbird.server.signal.port}"; }
          ];
        };
      };
    };
  };

  services.netbird.server = {
    enable = true;
    enableNginx = false;
    domain = netbirdDomain;
    signal.domain = netbirdDomain;

    coturn = {
      enable = true;
      domain = netbirdDomain;
      passwordFile = coturnPass;
    };

    dashboard = {
      domain = netbirdDomain;
      # https://github.com/netbirdio/netbird/blob/b65ec8b68a6a1ab8aee162a7b9e5147c0375af68/infrastructure_files/getting-started.sh#L931
      settings = {
        NETBIRD_MGMT_API_ENDPOINT = netbirdUrl;
        NETBIRD_MGMT_GRPC_API_ENDPOINT = netbirdUrl;
        AUTH_AUDIENCE = "netbird-dashboard";
        AUTH_CLIENT_ID = "netbird-dashboard";
        AUTH_AUTHORITY = "${netbirdUrl}/oauth2";
        AUTH_SUPPORTED_SCOPES = "openid profile email groups";
        AUTH_REDIRECT_URI = "/nb-auth";
        AUTH_SILENT_REDIRECT_URI = "/nb-silent-auth";
      };
    };

    management = {
      domain = netbirdDomain;
      turnDomain = netbirdDomain;
      oidcConfigEndpoint = "${netbirdUrl}/oauth2/.well-known/openid-configuration";
      settings = {
        Signal.URI = "${netbirdDomain}:443";
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
        EmbeddedIdP = {
          Enabled = true;
          DataDir = "${stateDir}/idp";
          Issuer = "${netbirdUrl}/oauth2";
          DashboardRedirectURIs = [
            "${netbirdUrl}/nb-auth"
            "${netbirdUrl}/nb-silent-auth"
          ];
        };
        EncryptionKey._secret = idpKey;
      };
    };
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

  services.httpd = {
    enable = true;
    virtualHosts.netbird-dashboard = {
      documentRoot = config.services.netbird.server.dashboard.finalDrv;
      hostName = netbirdDomain;
      listen = [
        {
          port = dashboardPort;
          ip = "localhost";
        }
      ];
      extraConfig = ''
        ErrorDocument 404 /404.html
      '';
    };
  };

}
