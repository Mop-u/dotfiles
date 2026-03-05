{
    config,
    pkgs,
    inputs,
    lib,
    ...
}:
let
    hmCfg = config.home-manager.users.${config.sidonia.userName};
    regreet = "${config.programs.regreet.package}/bin/regreet";
    setupScript = pkgs.writeShellScript "Compositor Setup" (
        lib.concatLines (
            lib.optional hmCfg.services.shikane.enable "${hmCfg.services.shikane.package}/bin/shikane -o -c ${hmCfg.home.homeDirectory}/.config/shikane/config.toml"
        )
    );
in
lib.mkMerge [
    {
        services.displayManager.sddm.enable = false;
        environment.pathsToLink = [
            "/share/wayland-sessions"
            "/share/xsessions"
        ];
        services.greetd = {
            enable = true;
        };
        programs.regreet = {
            enable = true;
            theme = {
                inherit (hmCfg.gtk.theme) package name;
            };
            cursorTheme = {
                inherit (hmCfg.gtk.cursorTheme) package name;
            };
            iconTheme = {
                inherit (hmCfg.gtk.iconTheme) package name;
            };
            font = {
                size = 16;
                inherit (config.sidonia.text.comicCode) package name;
            };
        };
    }
    (
        let
            start-hyprland = "${hmCfg.wayland.windowManager.hyprland.package}/bin/start-hyprland";
            hyprctl = "${hmCfg.wayland.windowManager.hyprland.package}/bin/hyprctl";
            hyprConf = pkgs.writeText "hyprland.conf" ''
                exec-once = ${setupScript}; ${regreet}; ${hyprctl} dispatch exit
                misc {
                    disable_hyprland_logo = true;
                    disable_splash_rendering = true;
                    disable_hyprland_guiutils_check = true;
                }
            '';
        in
        lib.mkIf (config.sidonia.desktop.compositor == "hyprland") {
            services.greetd.settings.default_session.command = "${pkgs.dbus}/bin/dbus-run-session ${start-hyprland} -- -c ${hyprConf}";
        }
    )
    (
        let
            niri = "${hmCfg.programs.niri.package}/bin/niri";
            niriConf = pkgs.writeTextFile "niri.kdl" ''
                spawn-sh-at-startup "${setupScript}; ${regreet}; ${niri} msg action quit --skip-confirmation"
                hotkey-overlay {
                    skip-at-startup
                }
                cursor {
                    // Change the theme and size of the cursor as well as set the
                    // `XCURSOR_THEME` and `XCURSOR_SIZE` env variables.
                    xcursor-theme "${config.programs.regreet.cursorTheme.name}"
                }
            '';
        in
        lib.mkIf (config.sidonia.desktop.compositor == "niri") {
            services.greetd.settings.default_session.command = "${pkgs.dbus}/bin/dbus-run-session ${niri} --config ${niriConf}";
        }
    )
]
