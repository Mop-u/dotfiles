# tty with modern font rendering
# https://github.com/Aetf/kmscon
{
    config,
    pkgs,
    inputs,
    lib,
    ...
}:
let
    cfg = config.sidonia;
    theme = cfg.style.catppuccin;
in
{
    options.sidonia.services.kmscon.enable =
        lib.mkEnableOption "Enable kmscon as a richer tty replacement";
    config =
        let
            configDir = pkgs.writeTextFile {
                name = "kmscon-config";
                destination = "/kmscon.conf";
                text =
                    let
                        rgb = lib.mapAttrs (n: v: v.rgb) theme.color;
                    in
                    with rgb;
                    ''
                        xkb-layout=${cfg.input.keyLayout}

                        font-size=14

                        palette=custom
                        palette-foreground=${text}
                        palette-background=${base}

                        palette-black=${surface1}
                        palette-red=${red}
                        palette-green=${green}
                        palette-yellow=${peach}
                        palette-blue=${blue}
                        palette-magenta=${pink}
                        palette-cyan=${lavender}
                        palette-light-grey=${subtext1}

                        palette-dark-grey=${surface2}
                        palette-light-red=${maroon}
                        palette-light-green=${teal}
                        palette-light-yellow=${yellow}
                        palette-light-blue=${sky}
                        palette-light-magenta=${flamingo}
                        palette-light-cyan=${sapphire}
                        palette-white=${text}

                        ${lib.optionalString config.hardware.graphics.enable ''
                            drm
                            hwaccel
                        ''}
                        ${lib.optionalString config.fonts.fontconfig.enable ''
                            font-name=${lib.strings.concatStringsSep ", " config.fonts.fontconfig.defaultFonts.monospace}
                        ''}
                    '';
            };
        in
        lib.mkIf cfg.services.kmscon.enable {
            # ensure services.kmscon does not screw with kmsconvt@.service
            #disabledModules = ["services/ttys/kmscon.nix"];
            services.kmscon.enable = lib.mkForce false;

            # add all systemd overrides from services/ttys/kmscon.nix aside from ExecStart as we have it patched in the package overlay
            systemd = {
                packages = [ pkgs.kmscon ];
                services = {
                    systemd-vconsole-setup.enable = false;
                    reload-systemd-vconsole-setup.enable = false;
                    "kmsconvt@" = {
                        after = [
                            "systemd-logind.service"
                            "systemd-vconsole-setup.service"
                        ];
                        requires = [ "systemd-logind.service" ];
                        restartIfChanged = false;
                        aliases = [ "autovt@.service" ];
                    };
                };
                suppressedSystemUnits = [ "autovt@.service" ];
            };

            nixpkgs.overlays = [
                (final: prev: {
                    kmscon = (
                        prev.kmscon.overrideAttrs {
                            src = inputs.kmscon;
                            buildInputs = with pkgs; [
                                util-linux
                                check
                                libGLU
                                libGL
                                libdrm
                                (libtsm.overrideAttrs { src = inputs.libtsm; }) # https://github.com/Aetf/kmscon/issues/64
                                libxkbcommon
                                pango
                                pixman
                                systemd
                                mesa
                            ];

                            env.NIX_CFLAGS_COMPILE =
                                "-O" # _FORTIFY_SOURCE requires compiling with optimization (-O)
                                # https://github.com/Aetf/kmscon/issues/49
                                + " -Wno-error=maybe-uninitialized"
                                # https://github.com/Aetf/kmscon/issues/64
                                + " -Wno-error=implicit-function-declaration";

                            patches = [
                                # Stop meson from writing systemd units to ${pkgs.systemd}/systemd/system, they should be written to ${pkgs.kmscon}/systemd/system
                                (pkgs.writeText "meson.build.patch" ''
                                    diff --git a/meson.build b/meson.build
                                    index 964b44b..fc043c7 100644
                                    --- a/meson.build
                                    +++ b/meson.build
                                    @@ -39,7 +39,7 @@ mandir = get_option('mandir')
                                     moduledir = get_option('libdir') / meson.project_name()
                                     
                                     systemd_deps = dependency('systemd', required: false)
                                    -systemdsystemunitdir = systemd_deps.get_variable('systemdsystemunitdir', default_value: get_option('libdir') / 'systemd/system')
                                    +systemdsystemunitdir = get_option('libdir') / 'systemd/system'
                                     
                                     #
                                     # Required dependencies
                                '')
                                # Fix agetty binary paths and link the configuration directory
                                (pkgs.writeText "kmscon.service.in.patch" ''
                                    diff --git a/docs/kmscon.service.in b/docs/kmscon.service.in
                                    index ad5600d..664bbfb 100644
                                    --- a/docs/kmscon.service.in
                                    +++ b/docs/kmscon.service.in
                                    @@ -6,7 +6,7 @@ After=systemd-user-sessions.service
                                     After=rc-local.service
                                     
                                     [Service]
                                    -ExecStart=@bindir@/kmscon --login -- /sbin/agetty -o '-p -- \\u' --noclear -- -
                                    +ExecStart=@bindir@/kmscon --configdir ${configDir} --login -- ${pkgs.util-linux}/bin/agetty -o '-p -- \\u' --noclear -- -
                                     
                                     [Install]
                                     WantedBy=multi-user.target
                                '')
                                (pkgs.writeText "kmsconvt@.service.in.patch" ''
                                    diff --git a/docs/kmsconvt@.service.in b/docs/kmsconvt@.service.in
                                    index a496e26..18a1f93 100644
                                    --- a/docs/kmsconvt@.service.in
                                    +++ b/docs/kmsconvt@.service.in
                                    @@ -38,7 +38,7 @@ IgnoreOnIsolate=yes
                                     ConditionPathExists=/dev/tty0
                                     
                                     [Service]
                                    -ExecStart=@bindir@/kmscon --vt=%I --seats=seat0 --no-switchvt --login -- /sbin/agetty -o '-p -- \\u' --noclear -- -
                                    +ExecStart=@bindir@/kmscon --vt=%I --seats=seat0 --no-switchvt --configdir ${configDir} --login -- ${pkgs.util-linux}/bin/agetty -o '-p -- \\u' --noclear -- -
                                     UtmpIdentifier=%I
                                     TTYPath=/dev/%I
                                     TTYReset=yes
                                '')
                            ];
                        }
                    );
                })
            ];
        };
}
