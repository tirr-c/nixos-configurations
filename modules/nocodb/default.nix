{ config, lib, pkgs, ... }:

let
  inherit (lib) types;
  cfg = config.services.nocodb;
  defaultUser = "nocodb";
in

{
  options.services.nocodb = {
    enable = lib.mkOption {
      type = types.bool;
      default = false;
    };

    package = lib.mkOption {
      type = types.package;
      default = pkgs.nocodb;
    };

    user = lib.mkOption {
      type = types.str;
      default = defaultUser;
    };

    group = lib.mkOption {
      type = types.str;
      default = defaultUser;
    };

    port = lib.mkOption {
      type = types.port;
      default = 8080;
    };

    publicUrl = lib.mkOption {
      type = types.nullOr types.str;
      default = null;
    };

    database = lib.mkOption {
      type = types.submodule {
        options = {
          backend = lib.mkOption {
            type = types.enum ["postgresql"];
            default = "postgresql";
          };
        };
      };

      default = { };
    };

    auth = lib.mkOption {
      type = types.submodule {
        options = {
          jwt = lib.mkOption {
            type = types.submodule {
              options = {
                secretPath = lib.mkOption {
                  type = types.externalPath;
                  default = "/var/lib/nocodb/jwt-secret";
                };

                expiresIn = lib.mkOption {
                  type = types.str;
                  default = "10h";
                };
              };
            };

            default = { };
          };

          admin = lib.mkOption {
            type = types.nullOr (types.submodule {
              options = {
                email = lib.mkOption {
                  type = types.str;
                };

                passwordPath = lib.mkOption {
                  type = types.externalPath;
                };
              };
            });

            default = null;
          };
        };
      };

      default = { };
    };

    storage = lib.mkOption {
      type = types.submodule {
        options = {
          maxAttachmentSize = lib.mkOption {
            type = types.ints.unsigned;
            default = 20 * 1024 * 1024;
          };

          maxNonAttachmentSize = lib.mkOption {
            type = types.ints.unsigned;
            default = 1 * 1024 * 1024;
          };
        };
      };

      default = { };
    };

    cacheKind = lib.mkOption {
      type = types.enum ["memory" "redis"];
      default = "redis";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users = lib.optionalAttrs (cfg.user == defaultUser) {
      ${defaultUser} = {
        isSystemUser = true;
        group = cfg.group;
      };
    };

    users.groups = lib.optionalAttrs (cfg.group == defaultUser) {
      ${defaultUser} = { };
    };

    services.postgresql = lib.mkIf (cfg.database.backend == "postgresql") {
      enable = true;
      ensureUsers = [
        {
          name = "nocodb";
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = ["nocodb"];
    };

    services.redis.servers.nocodb = lib.mkIf (cfg.cacheKind == "redis") {
      enable = true;
      user = cfg.user;
      port = 0; # Disable the TCP listener
    };

    systemd.tmpfiles.rules = [
      "f ${cfg.auth.jwt.secretPath} 0600 ${cfg.user} ${cfg.group} -"
    ];

    systemd.services.nocodb =
      let
        localRedisUrl = "redis+unix:///run/redis-nocodb/redis.sock";
        localPostgresqlUrl = "postgresql://localhost/nocodb?host=/run/postgresql";

        unitDeps =
          lib.optional (cfg.database.backend == "postgresql") "postgresql.target"
          ++ lib.optional (cfg.cacheKind == "redis") "redis-nocodb.service";
      in
      {
        description = "NocoDB";

        after = ["network.target"] ++ unitDeps;
        requires = unitDeps;

        before = ["multi-user.target"];
        wantedBy = ["multi-user.target"];

        environment = lib.mkMerge [
          {
            PORT = builtins.toString cfg.port;
            NUXT_PUBLIC_NC_BACKEND_URL = "http://localhost:${builtins.toString cfg.port}";

            NC_TOOL_DIR = "/var/lib/nocodb";
            NC_JWT_EXPIRES_IN = "${cfg.auth.jwt.expiresIn}";
            NC_ATTACHMENT_FIELD_SIZE = builtins.toString cfg.storage.maxAttachmentSize;
            NC_NON_ATTACHMENT_FIELD_SIZE = builtins.toString cfg.storage.maxNonAttachmentSize;

            PKG_NATIVE_CACHE_PATH = "/var/cache/nocodb";
          }

          (lib.mkIf (cfg.database.backend == "postgresql") {
            NC_DB_JSON = builtins.toJSON {
              client = "pg";
              connection = {
                connectionString = localPostgresqlUrl;
                database = "nocodb";
              };
            };
          })

          (lib.mkIf (cfg.auth.admin != null) {
            NC_ADMIN_EMAIL = "${cfg.auth.admin.email}";
          })

          (lib.mkIf (cfg.publicUrl != null) {
            NC_PUBLIC_URL = cfg.publicUrl;
          })

          (lib.mkIf (cfg.cacheKind == "redis") {
            NC_REDIS_URL = localRedisUrl;
          })
        ];

        path = [pkgs.coreutils];

        preStart = ''
          if [[ ! -s ${lib.escapeShellArg cfg.auth.jwt.secretPath} ]]; then
            head -c24 /dev/random | base64 > ${lib.escapeShellArg cfg.auth.jwt.secretPath}
          fi
        '';

        script = ''
          export NC_AUTH_JWT_SECRET=$(head -n1 ${lib.escapeShellArg cfg.auth.jwt.secretPath})
          ${lib.optionalString (cfg.auth.admin != null) ''
            export NC_ADMIN_PASSWORD=$(head -n1 ${lib.escapeShellArg cfg.auth.admin.passwordPath})
          ''}
          exec ${cfg.package}/bin/nocodb
        '';

        serviceConfig = {
          User = cfg.user;
          Group = cfg.group;
          Restart = "always";
          ProtectSystem = "strict";
          PrivateTmp = true;
          UMask = "0007";

          StateDirectory = "nocodb";
          StateDirectoryMode = "0750";
          RuntimeDirectory = "nocodb";
          RuntimeDirectoryMode = "0750";
          CacheDirectory = "nocodb";
          CacheDirectoryMode = "0750";
        };
      };
  };
}
