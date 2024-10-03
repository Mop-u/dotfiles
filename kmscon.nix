{ config, pkgs, inputs, lib, target, ... }:
{
    # tty with modern font rendering
    # https://github.com/Aetf/kmscon

    # TODO: stop services.kmscon from screwing with kmsconvt@.service
    services.kmscon = {
        enable = true;
        hwRender = true;
        fonts = (if target.text.comicCode.enable then [
            {name = target.text.comicCode.name; package = target.text.comicCode.package;}] else [])
        ++ [
            {name = "ComicShannsMono Nerd Font"; package = pkgs.nerdfonts;}
        ];
        extraConfig = ''
            xkb-layout=${target.input.keyLayout}

            font-size=14

            palette=custom
            palette-foreground=${target.style.catppuccin.text.rgb}
            palette-background=${target.style.catppuccin.base.rgb}

            palette-black=${target.style.catppuccin.surface1.rgb}
            palette-red=${target.style.catppuccin.red.rgb}
            palette-green=${target.style.catppuccin.green.rgb}
            palette-yellow=${target.style.catppuccin.peach.rgb}
            palette-blue=${target.style.catppuccin.blue.rgb}
            palette-magenta=${target.style.catppuccin.pink.rgb}
            palette-cyan=${target.style.catppuccin.lavender.rgb}
            palette-light-grey=${target.style.catppuccin.subtext1.rgb}

            palette-dark-grey=${target.style.catppuccin.surface2.rgb}
            palette-light-red=${target.style.catppuccin.maroon.rgb}
            palette-light-green=${target.style.catppuccin.teal.rgb}
            palette-light-yellow=${target.style.catppuccin.yellow.rgb}
            palette-light-blue=${target.style.catppuccin.sky.rgb}
            palette-light-magenta=${target.style.catppuccin.flamingo.rgb}
            palette-light-cyan=${target.style.catppuccin.sapphire.rgb}
            palette-white=${target.style.catppuccin.text.rgb}
        '';
    };

    nixpkgs.overlays = [
        (final: prev: {
            kmscon = (prev.kmscon.overrideAttrs{
                src = inputs.kmscon;
                buildInputs = with pkgs; [
                    util-linux
                    check
                    libGLU
                    libGL
                    libdrm
                    # https://github.com/Aetf/kmscon/issues/64
                    (libtsm.overrideAttrs{src=inputs.libtsm;})
                    libxkbcommon
                    pango
                    pixman
                    systemd
                    mesa
                ];

                patches = [
                    (pkgs.writeTextFile {
                        name = "meson.build.patch";
                        text = ''
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
                        '';
                    })
                    (pkgs.writeTextFile {
                        name = "kmscon.service.in.patch";
                        text = ''
                            diff --git a/docs/kmscon.service.in b/docs/kmscon.service.in
                            index ad5600d..664bbfb 100644
                            --- a/docs/kmscon.service.in
                            +++ b/docs/kmscon.service.in
                            @@ -6,7 +6,7 @@ After=systemd-user-sessions.service
                             After=rc-local.service
                             
                             [Service]
                            -ExecStart=@bindir@/kmscon --login -- /sbin/agetty -o '-p -- \\u' --noclear -- -
                            +ExecStart=@bindir@/kmscon --login -- ${pkgs.util-linux}/bin/agetty -o '-p -- \\u' --noclear -- -
                             
                             [Install]
                             WantedBy=multi-user.target
                         '';
                    })
                    (pkgs.writeTextFile {
                        name = "kmsconvt@.service.in.patch";
                        text = ''
                            diff --git a/docs/kmsconvt@.service.in b/docs/kmsconvt@.service.in
                            index a496e26..18a1f93 100644
                            --- a/docs/kmsconvt@.service.in
                            +++ b/docs/kmsconvt@.service.in
                            @@ -38,7 +38,7 @@ IgnoreOnIsolate=yes
                             ConditionPathExists=/dev/tty0
                             
                             [Service]
                            -ExecStart=@bindir@/kmscon --vt=%I --seats=seat0 --no-switchvt --login -- /sbin/agetty -o '-p -- \\u' --noclear -- -
                            +ExecStart=@bindir@/kmscon --vt=%I --seats=seat0 --no-switchvt --login -- ${pkgs.util-linux}/bin/agetty -o '-p -- \\u' --noclear -- -
                             UtmpIdentifier=%I
                             TTYPath=/dev/%I
                             TTYReset=yes
                        '';
                    })
                ];

                env.NIX_CFLAGS_COMPILE = "-O" # _FORTIFY_SOURCE requires compiling with optimization (-O)
                    # https://github.com/Aetf/kmscon/issues/49
                    + " -Wno-error=maybe-uninitialized"
                    # https://github.com/Aetf/kmscon/issues/64
                    + " -Wno-error=implicit-function-declaration";
            });
        })
    ];
}
