{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:
let
    cfg = config.sidonia;
    inherit (cfg) window;
    theme = cfg.style.catppuccin;
    bemenu =
        let
            palette = builtins.mapAttrs (n: v: "##${v.hex}") theme.color;
            opacity = window.opacity.hex;
        in
        with palette;
        rec {
            placement = " -nciwl '16 down' --single-instance --width-factor 0.33";
            border = " --border ${builtins.toString window.borderSize} --border-radius ${builtins.toString window.rounding}";
            tb = " --tb '${base}${opacity}'";
            fb = " --fb '${base}${opacity}'";
            nb = " --nb '${base}${opacity}'";
            ab = " --ab '${base}${opacity}'";
            hb = " --hb '${base}${opacity}'";
            tf = " --tf '${accent}'";
            ff = " --ff '${text}'";
            nf = " --nf '${text}'";
            af = " --af '${text}'";
            hf = " --hf '${accent}'";
            bdr = " --bdr '${accent}'";
            font = " --fn monospace";
            opts = placement + border + tb + fb + nb + ab + hb + tf + ff + nf + af + hf + bdr + font;
        };

in
lib.mkIf (cfg.graphics.enable) {
    home-manager.users.${cfg.userName} = {
        programs.bemenu.enable = true;
        wayland.windowManager.hyprland.settings.bind =
            [
                "SUPER, P, exec, uwsm app -- $(bemenu-run --no-exec ${bemenu.opts})"
            ]
            ++ (
                if config.hardware.nvidia.prime.offload.enableOffloadCmd then
                    [
                        "SUPERSHIFT, P, exec, uwsm app -- nvidia-offload $(LIBVA_DRIVER_NAME=nvidia VDPAU_NAME=nvidia bemenu-run --no-exec ${bemenu.opts})"
                    ]
                else
                    [ ]
            );
    };
}
