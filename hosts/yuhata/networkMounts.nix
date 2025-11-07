{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:
let
    mntBenisuzume = name: {
        fsType = "cifs";
        device = "//10.0.4.3/${name}";
        options = [
            "credentials=${config.sops.secrets."benisuzume/cifs".path}"
            "x-systemd.automount"
            "x-systemd.idle-timeout=30"
            "nofail"
            "uid=${config.sidonia.userName}"
            "gid=users"
            "rw"
            "rwpidforward"
            "exec"
            "hard"
            "fsc"
        ];
    };
in
{
    services.rpcbind.enable = true;
    environment.systemPackages = [ pkgs.cifs-utils ];

    sops.secrets."benisuzume/cifs" = { };

    fileSystems."/mnt/benisuzume" = mntBenisuzume "personal-drive";

    services.cachefilesd.enable = true;
}
