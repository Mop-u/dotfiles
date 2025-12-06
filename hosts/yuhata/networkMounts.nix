{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:
let
    benisuzumeIP = "10.0.4.3";
    unasCIFS = addr: name: "//${addr}/${name}";
    unasNFS = addr: name: "${addr}:/var/nfs/shared/${name}";

    mntUnasCIFS = addr: name: {
        fsType = "cifs";
        device = unasCIFS addr name;
        options = [
            "credentials=${config.sops.secrets."benisuzume/cifs".path}"
            "uid=${config.sidonia.userName}"
            "gid=users"
            "rw"
            "exec"
            "nofail"
            "x-systemd.automount"
            "x-systemd.device-timeout=60s"
            "fsc"
        ];
    };

    mntUnasNFS = addr: name: {
        fsType = "nfs";
        device = unasNFS addr name;
        options = [
            "hard"
            "noacl"
            "noatime"
            "nodiratime"
            "x-systemd.automount"
            "x-systemd.device-timeout=60s"
            "nofail"
            "fsc"
        ];
    };

    mntBenisuzumeCIFS = name: mntUnasCIFS benisuzumeIP name;
    mntBenisuzumeNFS = name: mntUnasNFS benisuzumeIP name;
in
{
    services.rpcbind.enable = true;
    boot.supportedFilesystems = [ "nfs" ];
    environment.systemPackages = [
        pkgs.nfs-utils
        pkgs.cifs-utils
    ];

    sops.secrets."benisuzume/cifs" = { };

    fileSystems."/mnt/benisuzume" = mntBenisuzumeCIFS "personal-drive";
    fileSystems."/mnt/steam" = mntBenisuzumeNFS "steam";

    services.cachefilesd = {
        enable = true;
        extraConfig = ''
            brun 30%
            bcull 20%
            bstop 10%
        '';
    };
}
