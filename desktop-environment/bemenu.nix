{inputs, config, pkgs, lib, target, ... }: let

    bemenu = rec {
        placement = " -nciwl '16 down' --single-instance --width-factor 0.33";
        border    = " --border ${target.window.borderSize} --border-radius ${target.window.rounding}";
        tb        = " --tb '##${target.style.catppuccin.base.hex}${target.window.opacity.hex}'";
        fb        = " --fb '##${target.style.catppuccin.base.hex}${target.window.opacity.hex}'";
        nb        = " --nb '##${target.style.catppuccin.base.hex}${target.window.opacity.hex}'";
        ab        = " --ab '##${target.style.catppuccin.base.hex}${target.window.opacity.hex}'";
        hb        = " --hb '##${target.style.catppuccin.base.hex}${target.window.opacity.hex}'";
        tf        = " --tf '##${target.style.catppuccin.highlight.hex}'";
        ff        = " --ff '##${target.style.catppuccin.text.hex}'";
        nf        = " --nf '##${target.style.catppuccin.text.hex}'";
        af        = " --af '##${target.style.catppuccin.text.hex}'";
        hf        = " --hf '##${target.style.catppuccin.highlight.hex}'";
        bdr       = " --bdr '##${target.style.catppuccin.highlight.hex}'";
        font      = " --fn monospace";
        opts = placement + border + tb + fb + nb + ab + hb + tf + ff + nf + af + hf + bdr + font;
    };

in {
    home-manager.users.${target.userName} = {
        programs.bemenu.enable = true;
        wayland.windowManager.hyprland.settings.bind = [
            "SUPER, P, exec, bemenu-run ${bemenu.opts}"
        ]
        ++ (if config.hardware.nvidia.prime.offload.enableOffloadCmd then [
            "SUPERSHIFT, P, exec, LIBVA_DRIVER_NAME=nvidia VDPAU_NAME=nvidia nvidia-offload $(bemenu-run --no-exec ${bemenu.opts})"
        ] else []);
    };
}