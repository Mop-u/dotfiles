{
    config,
    pkgs,
    inputs,
    lib,
    ...
}:
let
    # See: https://github.com/wlx-team/wayvr/wiki
    wayvrConfig =
        with (builtins.mapAttrs (n: v: "#${v.hex}") config.sidonia.style.catppuccin.color);
        (pkgs.formats.yaml { }).generate "config.yaml" {
            # This is the main config for WayVR
            # Place this file in ~/.config/wayvr/conf.d and tweak the values.
            # Default values are shown unless noted otherwise.

            # In case you're not getting the expected result,
            # check the logs at /tmp/wlx.log for parsing errors.

            ## Only if built with `osc` feature. What port to send OSC messages to.
            #osc_out_port: 9000

            ## Set your preferred watch timezones here.
            timezones = [
                "Europe/Dublin"
            ];

            ## On most desktops, WayVR is able to pick up your keymap via wayland. (Especially when using Fcitx5!)
            ## However, if this does not happen, you might want to set your keymap by hand.
            ## When using a simple layout:
            #default_keymap: us
            #
            ## When defining a layout-variant pair, separate using a dash:
            #default_keymap: us-colemak_dh

            ## Path to read the custom theme from, relative to `~/.config/wayvr`
            #theme_path: "theme"

            ## These can be used to control the color theme of WayVR.
            color_text = text;
            color_accent = accent;
            color_danger = flamingo;
            color_faded = overlay0;
            color_background = base;

            ## Path to custom skybox texture, relative to `~/.config/wayvr`
            #skybox_texture: ""

            ## User-defined list of custom overlays that should be created.
            ## Each entry must correspond to an XML file at: {theme_path}/gui/{entry}.xml
            #custom_panels:
            # - "test"

            ## The alt_click binding can be used to execute a program of choice
            ## These are not default, but example values.
            #alt_click_down: ["bash", "-c", "echo x"]
            #alt_click_up: ["bash", "-c", "echo y"]

            ## Example for quick-calibration with `motoc`:
            #alt_click_down:
            #  [
            #    "motoc",
            #    "calibrate",
            #    "--src",
            #    "WiVRn HMD",
            #    "--dst",
            #    "LHR-AABBCCDD",
            #    "--samples",
            #    "200",
            #  ]

            ## Set what kind of notifications to show and what to hide
            #notification_topics:
            #  System: Center
            #  DesktopNotification: Center
            #  XSNotification: Center
            #  IpdChange: Hide

            ## Path to a custom notification sound, relative to `~/.config/wayvr`
            #notification_sound: ""

            ## If `screen_render_down` is enabled,
            ## controls the maximum height of the screen
            #screen_max_height: 1440

            ## Don't move the mouse more often than this value
            ## helps to avoid unnecessary load when pairing
            ## a high-refresh screen with a lower-refresh hmd
            #mouse_move_interval_ms: 10
        };
in
{
    # https://github.com/NixOS/nixpkgs/pull/479448
    home-manager.users.${config.sidonia.userName} = {
        home.packages = [
            pkgs.wayvr
        ];
        xdg.configFile."wayvr/conf.d/config.yaml".source = wayvrConfig;
    };
}
