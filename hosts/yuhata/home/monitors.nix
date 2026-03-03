{
    osConfig,
    config,
    pkgs,
    inputs,
    lib,
    ...
}:
let
    tv = "d%Q90A";
    zowie = "d%ZOWIE";
    ultrawide = "d%P40w-20";
in
{
    services.shikane = {
        enable = true;
        settings.profile = [
            {
                name = "Workstation Monitors";
                output = [
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
                name = "Living Room TV";
                output = [
                    {
                        search = tv;
                        enable = true;
                        scale = 1.5;
                        adaptive_sync = true;
                        mode = "3840x2160@120";
                        position = "0,0";
                    }
                ];
            }
        ];
    };
}
