{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:
{
    sops.secrets."tsumugi/nutPass" = { };
    power.ups = {
        enable = false;
        mode = "netserver";
        openFirewall = true;
        users.powercoolmon = {
            passwordFile = config.sops.secrets."tsumugi/nutPass".path;
            upsmon = "primary";
        };
        upsd.listen = [
            {
                address = "10.0.4.2";
                port = 3493;
            }
        ];
        upsmon = {
            settings.NOTIFYFLAG = [
                [
                    "COMMOK"
                    "SYSLOG"
                ]
                [
                    "COMMBAD"
                    "SYSLOG"
                ]
                [
                    "NOCOMM"
                    "SYSLOG"
                ]
            ];
            monitor.powercool = {
                user = "powercoolmon";
                type = "primary";
                system = "powercool@localhost:3493";
                powerValue = 1;
                passwordFile = config.sops.secrets."tsumugi/nutPass".path;
            };
        };
        ups.powercool = {
            description = "Powercool UPS 1500VA";
            driver = "nutdrv_qx";
            port = "auto";
            directives = [
                "vendorid = 0001"
                "productid = 0000"
                "product = \"MEC0003\""
                "protocol = hunnox"
                "langid_fix = 0x409"
                "novendor"
                "noscanlangid"
            ];
        };
    };
}
