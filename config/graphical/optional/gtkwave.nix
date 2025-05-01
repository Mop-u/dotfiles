{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:
let
    cfg = config.sidonia;
in
{
    options.sidonia.programs = with lib; {
        gtkwave = {
            enable = mkEnableOption "Enable gtkwave";
        };
    };
    config = lib.mkIf cfg.programs.gtkwave.enable {
        home-manager.users.${cfg.userName}.home = {
            packages = with pkgs; [ gtkwave ];
            file.gtkwaverc = {
                enable = true;
                target = "/home/${cfg.userName}/.gtkwaverc";
                text = with lib.mapAttrs (n: v: v.hex) cfg.style.catppuccin.color; let
                    traceRegular = green;
                    traceVector = green;
                    traceDontCare = yellow;
                    traceTriState = teal;
                    traceUndefined = red;
                in ''
                    highlight_wavewindow 1
                    fill_waveform 1
                    clipboard_mouseover 1
                    disable_mouseover 0
                    show_base_symbols 0
                    fontname_signals Monospace 12
                    fontname_waves Monospace 12

                    # background color
                    color_back   ${base}
                    # text color for timebar's background
                    color_timeb ${mantle}
                    # text color for timebar
                    color_time ${text}

                    # color value for "normal" GTK state in signal window
                    color_normal ${green}
                    # brick red color for comments
                    color_brkred ${red}
                    # color value for "dark blue" in signal window
                    color_dkblue ${accent}
                    # color for shadowed traces
                    color_ltblue ${sky}

                    # color value for trace groupings
                    color_gmstrd ${maroon}

                    # grid color (use Alt+G to show/hide grid). This is also the color used for high-light_wavewindow when enabled.
                    color_grid   ${mantle}

                    # grid color for secondary pattern search
                    color_grid2  ${flamingo}

                    # middle mouse button marker color
                    color_baseline ${text}
                    # color of the named markers
                    color_mark   ${peach}
                    # color of the unnamed (primary) marker
                    color_umark  ${mauve}

                    # color value for "white" in signal window
                    color_white ${base}
                    # color value for "black" in signal window
                    color_black ${text}
                    # color value for "light gray" in signal window
                    color_ltgray ${base}
                    # color value for "medium gray" in signal window
                    color_mdgray ${mantle}
                    # color value for "dark gray" in signal window
                    color_dkgray ${crust}

                    # text color for vector values
                    color_value  ${text}
                    # vector color (horizontal)
                    color_vbox   ${traceVector}
                    # vector color (verticals/transitions)
                    color_vtrans ${traceVector}

                    # trace color when 0
                    color_0      ${traceRegular}
                    # trace color when 1
                    color_1      ${traceRegular}
                    # trace color (inside of box) when 1
                    color_1fill  ${traceRegular}
                    # trace color when transitioning
                    color_trans  ${traceRegular}

                    # trace color when don't care ("-")
                    color_dash   ${traceDontCare}
                    # trace color (inside of box) when don't care ("-")
                    color_dashfill ${traceDontCare}

                    # trace color when weak ("W")
                    color_w      ${traceTriState}
                    # trace color when high ("H")
                    color_high   ${traceTriState}
                    # trace color when low ("L")
                    color_low    ${traceTriState}
                    # trace color when floating ("Z")
                    color_mid    ${traceTriState}
                    # trace color (inside of box) when weak ("W")
                    color_wfill  ${traceTriState}
                    # trace color (inside of box) when high ("H")
                    color_highfill ${traceTriState}

                    # trace color when undefined ("X") (collision for VHDL)
                    color_x      ${traceUndefined}
                    # trace color (inside of box) when undefined ("X") (collision for VHDL)
                    color_xfill  ${traceUndefined}
                    # trace color when undefined ("U")
                    color_u      ${traceUndefined}
                    # trace color (inside of box) when undefined ("U")
                    color_ufill  ${traceUndefined}
                '';
            };
        };
    };
}
