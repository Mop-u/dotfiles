{
    config,
    pkgs,
    inputs,
    lib,
    ...
}:
let
    cfg = config.sidonia;
in
{
    options.sidonia.services.audio.enable =
        with lib;
        mkOption {
            type = types.bool;
            default = cfg.graphics.enable;
        };
    config = lib.mkIf (cfg.services.audio.enable) {
        # https://cmm.github.io/soapbox/the-year-of-linux-on-the-desktop.html
        hardware.pulseaudio.enable = false; # using pipewire instead
        services.pipewire = {
            enable = true;
            audio.enable = true;
            alsa = {
                enable = true;
                support32Bit = true;
            };
            pulse.enable = true;
        };

        # Audio stutter prevention
        boot.kernelParams = [ "threadirqs" ];
        security.rtkit.enable = true;

        # allow members of "audio" to set RT priorities up to 90
        security.pam.loginLimits = [
            {
                domain = "@audio";
                type = "-";
                item = "rtprio";
                value = "90";
            }
        ];
        # expose important timers etc. to "audio"
        services.udev.extraRules = ''
            DEVPATH=="/devices/virtual/misc/cpu_dma_latency", OWNER="root", GROUP="audio", MODE="0660"
            DEVPATH=="/devices/virtual/misc/hpet", OWNER="root", GROUP="audio", MODE="0660"
        '';

        # explicitly set Pipewire RT params (may not be necessary)
        services.pipewire.extraConfig.pipewire."99-rtparams" = {
            "context.modules" = [
                {
                    name = "libpipewire-module-rt";
                    args = {
                        "nice.level" = -11;
                        "rt.prio" = 19;
                    };
                }
            ];
        };

        # increase output headroom.  this may make latency worse (not sure how
        # noticeably) -- so if you game you may want to first try doing
        # without it
        environment.etc."wireplumber/main.lua.d/99-alsa-config.lua".text = ''
            -- prepend, otherwise the change-nothing stock config will match first:
            table.insert(alsa_monitor.rules, 1, {
                matches = {
                {
                    -- Matches all sinks.
                    { "node.name", "matches", "alsa_output.*" },
                },
                },
                apply_properties = {
                ["api.alsa.headroom"] = 1024,
                },
            })
        '';

        users.users.${cfg.userName}.extraGroups = [
            "audio"
            "rtkit"
        ];
    };
}
