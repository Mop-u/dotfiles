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
    bemenu = rec {
        placement = " -nciwl '16 down' --single-instance --width-factor 0.33";
        border = " --border ${builtins.toString window.borderSize} --border-radius ${builtins.toString window.rounding}";
        tb = " --tb '##${theme.base.hex}${window.opacity.hex}'";
        fb = " --fb '##${theme.base.hex}${window.opacity.hex}'";
        nb = " --nb '##${theme.base.hex}${window.opacity.hex}'";
        ab = " --ab '##${theme.base.hex}${window.opacity.hex}'";
        hb = " --hb '##${theme.base.hex}${window.opacity.hex}'";
        tf = " --tf '##${theme.highlight.hex}'";
        ff = " --ff '##${theme.text.hex}'";
        nf = " --nf '##${theme.text.hex}'";
        af = " --af '##${theme.text.hex}'";
        hf = " --hf '##${theme.highlight.hex}'";
        bdr = " --bdr '##${theme.highlight.hex}'";
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
