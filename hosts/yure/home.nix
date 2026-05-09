
{
    osConfig,
    config,
    pkgs,
    inputs,
    lib,
    ...
}:
{
    programs = {
        sublime4.enable = false;
        niri.settings = {
            layout.default-column-width.proportion = 1.;
            debug = {
                # disable-cursor-plane = [];
                # disable-direct-scanout = [];
                # enable-overlay-planes = [];
            };
        };
    };
    services.shikane = {
        enable = true;
        settings.profile = [
            {
                name = "Undocked";
                output = [
                    {
                        enable = true;
                        search = "n=LVDS-1";
                        scale = 1.0;
                    }
                ];
            }
        ];
    };
}
