{
    osConfig,
    config,
    pkgs,
    inputs,
    lib,
    ...
}:
let
    laptop = "n=eDP-1";
    zowie = "d%ZOWIE";
    ultrawide = "d%P40w-20";
in
{
    services.shikane = {
        enable = true;
        settings.profile = [
            {
                name = "Docked at Workstation";
                output = [
                    {
                        search = laptop;
                        enable = false;
                    }
                    {
                        search = zowie;
                        enable = true;
                        scale = 1.0;
                        mode = "1920x1080@60";
                        position = "4800,400";
                    }
                    {
                        search = ultrawide;
                        enable = true;
                        scale = 1.07;
                        mode = "5120x2160@74.98";
                        position = "0,0";
                    }
                ];
            }
            {
                name = "Undocked";
                output = [
                    {
                        search = laptop;
                        enable = true;
                        scale = 1.0;
                        adaptive_sync = true;
                        mode = "2560x1600@165";
                        position = "0,0";
                    }
                ];
            }
        ];
    };
}
