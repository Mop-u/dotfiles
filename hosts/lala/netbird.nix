{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
let
  unstable = inputs.unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  domain = "moppu.dev";
  netbirdDomain = "netbird.${domain}";
  netbirdUrl = "https://${netbirdDomain}";
  stateDir = "/var/lib/netbird-mgmt";
  dashboardPort = 1234;
  relayPort = 33080;
  proxyPort = 8443;
  coturnPass = config.sops.secrets."lala/netbird/coturnPass".path;
  dataStoreKey = config.sops.secrets."lala/netbird/dataStoreKey".path;
  relaySecret = config.sops.secrets."lala/netbird/relaySecret".path;
  relaySecretEnv = config.sops.secrets."lala/netbird/relaySecretEnv".path;
  proxySecret = config.sops.secrets."lala/netbird/proxySecret".path;
  proxySecretEnv = config.sops.secrets."lala/netbird/proxySecretEnv".path;
  idpKey = config.sops.secrets."lala/netbird/idpKey".path;
in
{
  sops.secrets = {
    "lala/netbird/coturnPass".owner = config.users.users.turnserver.name;
    "lala/netbird/dataStoreKey" = { };
    "lala/netbird/relaySecret" = { };
    "lala/netbird/relaySecretEnv" = { };
    "lala/netbird/proxySecret" = { };
    "lala/netbird/proxySecretEnv" = { };
    "lala/netbird/idpKey" = { };
  };

  networking.firewall = {
    allowedTCPPorts = [
      80
      443
      3478
      10000
      relayPort
      25565
    ];
    allowedUDPPorts = [
      3478
      5349
      relayPort
      8211
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
      tcp = {
        routers = {
          proxy-passthrough = {
            rule = "HostSNI(`*`)";
            entryPoints = "websecure";
            tls.passthrough = true;
            service = "proxy-tls";
            priority = 1;
          };
        };
        services.proxy-tls.loadBalancer.servers = [
          { address = "localhost:${toString proxyPort}"; }
        ];
      };
      http = {
        routers = {
          netbird-dashboard = {
            rule = "Host(`${netbirdDomain}`)";
            entryPoints = "websecure";
            tls.certResolver = "letsencrypt";
            service = "netbird-dash";
            priority = 10;
          };
          netbird-signal = {
            rule = "Host(`${netbirdDomain}`) && PathPrefix(`/ws-proxy/signal`)";
            entryPoints = "websecure";
            tls.certResolver = "letsencrypt";
            service = "netbird-signal";
            priority = 100;
          };
          netbird-signal-grpc = {
            rule = "Host(`${netbirdDomain}`) && PathPrefix(`/signalexchange.SignalExchange/`)";
            entryPoints = "websecure";
            tls.certResolver = "letsencrypt";
            service = "netbird-signal-grpc";
            priority = 100;
          };
          netbird-backend = {
            rule = "Host(`${netbirdDomain}`) && (PathPrefix(`/relay`) || PathPrefix(`/ws-proxy/management`) || PathPrefix(`/api`) || PathPrefix(`/oauth2`))";
            entryPoints = "websecure";
            tls.certResolver = "letsencrypt";
            service = "netbird-server";
            priority = 100;
          };
          netbird-backend-grpc = {
            rule = "Host(`${netbirdDomain}`) && (PathPrefix(`/management.ManagementService/`) || PathPrefix(`/management.ProxyService/`))";
            entryPoints = "websecure";
            tls.certResolver = "letsencrypt";
            service = "netbird-server-grpc";
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
          netbird-server-grpc.loadBalancer.servers = [
            { url = "h2c://localhost:${toString config.services.netbird.server.management.port}"; }
          ];
          netbird-signal.loadBalancer.servers = [
            { url = "http://localhost:${toString config.services.netbird.server.signal.port}"; }
          ];
          netbird-signal-grpc.loadBalancer.servers = [
            { url = "h2c://localhost:${toString config.services.netbird.server.signal.port}"; }
          ];
        };
      };
    };
  };

  # Keep nginx config for the dashboard but listen on an internal port instead of port 80
  services.nginx.virtualHosts.${config.services.netbird.server.dashboard.domain}.listen = [
    {
      port = dashboardPort;
      addr = "localhost";
    }
  ];

  services.netbird = {
    package = unstable.netbird;
    server = {
      enable = true;
      enableNginx = false;
      domain = netbirdDomain;

      signal = {
        package = unstable.netbird-signal;
        domain = netbirdDomain;
      };

      coturn = {
        enable = true;
        domain = netbirdDomain;
        passwordFile = coturnPass;
      };

      dashboard = {
        package = unstable.netbird-dashboard;
        domain = netbirdDomain;
        enableNginx = true;
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
        package = unstable.netbird-management;
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
  };

  systemd.services = {
    netbird-relay = {
      enable = true;
      description = "The relay service for Netbird, a wireguard VPN";
      documentation = [ "https://netbird.io/docs/" ];
      after = [
        "network.target"
        "netbird-management.service"
      ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        NB_LOG_LEVEL = "info";
        NB_LISTEN_ADDRESS = ":${toString relayPort}";
        NB_EXPOSED_ADDRESS = "rels://${netbirdDomain}:${toString relayPort}";
        NB_HEALTH_LISTEN_ADDRESS = ":9999";
        NB_METRICS_PORT = "9998";
        NB_TLS_CERT_FILE = "/var/lib/acme/${netbirdDomain}/fullchain.pem";
        NB_TLS_KEY_FILE = "/var/lib/acme/${netbirdDomain}/key.pem";
      };
      serviceConfig = {
        EnvironmentFile = relaySecretEnv;
        ExecStart = lib.getExe unstable.netbird-relay;
        Restart = "always";

        # hardening
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateMounts = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = true;
        RemoveIPC = true;
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
      };
      stopIfChanged = false;
    };
    netbird-proxy = {
      enable = true;
      description = "The proxy service for Netbird, a wireguard VPN";
      documentation = [ "https://netbird.io/docs/" ];
      after = [
        "network.target"
        "netbird-management.service"
      ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        NB_PROXY_DOMAIN = "proxy.moppu.dev";
        NB_PROXY_MANAGEMENT_ADDRESS = "http://localhost:${toString config.services.netbird.server.management.port}";
        NB_PROXY_ALLOW_INSECURE = "true";
        NB_PROXY_ADDRESS = ":${toString proxyPort}";
        NB_PROXY_ACME_CERTIFICATES = "true";
        NB_PROXY_ACME_CHALLENGE_TYPE = "tls-alpn-01";
        NB_PROXY_CERTIFICATE_DIRECTORY = "/var/lib/proxy-certs";
        NB_PROXY_LOG_LEVEL = "info";
      };
      serviceConfig = {
        EnvironmentFile = proxySecretEnv;
        ExecStart = lib.getExe unstable.netbird-proxy;
        Restart = "always";

        # hardening
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateMounts = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = true;
        RemoveIPC = true;
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
      };
      stopIfChanged = false;
    };
  };
}
