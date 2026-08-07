{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.bandcampsync;
in
{
  options.services.bandcampsync = {
    enable = lib.mkEnableOption "Enable bandcampsync service";
    package = lib.mkPackageOption pkgs "bandcampsync" { };
    user = lib.mkOption {
      type = lib.types.str;
      default = "bandcampsync";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = "bandcampsync";
    };
    stateDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/bandcampsync";
    };
    settings = {
      cookies = lib.mkOption {
        description = "Path to the cookies file";
        type = lib.types.path;
        default = "${cfg.stateDir}/cookies.txt";
      };
      directory = lib.mkOption {
        description = "Path to the directory to download media to";
        type = lib.types.path;
        default = "${cfg.stateDir}/downloads";
      };
      ignore = lib.mkOption {
        description = "A list of patterns matching artists to bypass";
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
      ignoreFile = lib.mkOption {
        description = "Path to the ignore file";
        type = lib.types.path;
        default = "${cfg.stateDir}/ignores.txt";
      };
      format = lib.mkOption {
        description = "Media format to download";
        type = lib.types.enum [
          "mp3-v0"
          "mp3-320"
          "flac"
          "aac-hi"
          "aiff-lossless"
          "vorbis"
          "alac"
          "wav"
        ];
        default = "flac";
      };
      runDailyAt = lib.mkOption {
        type = lib.types.enum (lib.range 0 23);
        default = 3;
      };
      tempDir = lib.mkOption {
        description = "Path to use for temporary downloads";
        type = lib.types.nullOr lib.types.path;
        default = null;
      };
      notifyUrl = lib.mkOption {
        description = "URL to notify with a GET request when any new downloads have completed";
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      concurrency = lib.mkOption {
        description = "Number of concurrent downloads";
        type = lib.types.ints.positive;
        default = 1;
      };
      untilDate = lib.mkOption {
        description = "Process purchases down to this purchase date (YYYY-MM-DD, inclusive)";
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      maxRetries = lib.mkOption {
        description = "Maximum number of retries for a download";
        type = lib.types.ints.positive;
        default = 3;
      };
      retryWait = lib.mkOption {
        description = "Number of seconds to wait between retries";
        type = lib.types.ints.positive;
        default = 5;
      };
      skipItemIndex = lib.mkEnableOption "Skip indexing downloaded items in the filesystem; only use ignore file for to determining which items are downloaded already";
      syncIgnoreFile = lib.mkEnableOption "Add already downloaded items found in filesystem to ignore file";
      skipHidden = lib.mkEnableOption "Skip items that have the hidden flag set";
      dryRun = lib.mkEnableOption "List items that would be downloaded without downloading or writing files";
    };
    extraEnv = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.nullOr (
          lib.types.oneOf [
            lib.types.str
            lib.types.package
            lib.types.path
          ]
        )
      );
      default = { };
    };
  };
  config = lib.mkIf cfg.enable {
    users.users = lib.optionalAttrs (cfg.user == "bandcampsync") {
      bandcampsync = {
        inherit (cfg) group;
        description = "bandcampsync user";
        isSystemUser = true;
      };
    };
    users.groups = lib.optionalAttrs (cfg.group == "bandcampsync") {
      bandcampsync = { };
    };
    systemd = {
      tmpfiles.rules = [
        "d ${cfg.stateDir} 0700 ${cfg.user} ${cfg.group} -"
        "d ${cfg.settings.directory} 0755 ${cfg.user} ${cfg.group} -"
      ];
      services.bandcampsync = {
        enable = true;
        description = "Automatic downloader for bandcamp purchases";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        environment = {
          COOKIES_FILE = cfg.settings.cookies;
          DIRECTORY = cfg.settings.directory;
          IGNORES_FILE = cfg.settings.ignoreFile;
          IGNORE = lib.concatStringsSep " " cfg.settings.ignore;
          FORMAT = cfg.settings.format;
          RUN_DAILY_AT = toString cfg.settings.runDailyAt;
          TEMP_DIR = cfg.settings.tempDir;
          NOTIFY_URL = cfg.settings.notifyUrl;
          UNTIL_DATE = cfg.settings.untilDate;
          DRY_RUN = lib.boolToString cfg.settings.dryRun;
          MAX_RETRIES = toString cfg.settings.maxRetries;
          RETRY_WAIT = toString cfg.settings.retryWait;
          CONCURRENCY = toString cfg.settings.concurrency;
          SKIP_ITEM_INDEX = lib.boolToString cfg.settings.skipItemIndex;
          SYNC_IGNORE_FILE = lib.boolToString cfg.settings.syncIgnoreFile;
          SKIP_HIDDEN = lib.boolToString cfg.settings.skipHidden;
          EXIT_AFTER_RUN = "0";
          TZ = config.time.timeZone or "UTC";
        }
        // cfg.extraEnv;
        serviceConfig = {
          User = cfg.user;
          Group = cfg.group;
          ExecStart = "${cfg.package}/bin/bandcampsync-service";
        };
      };
    };
  };
}
