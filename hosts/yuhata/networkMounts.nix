{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:
let
    useNFS = false;
    hardMount = true;
    mntBenisuzume = name: {
        fsType = if useNFS then "nfs" else "cifs";
        device = if useNFS then "10.0.4.3:/var/nfs/shared/${name}" else "//10.0.4.3/${name}";
        options =
            (
                if useNFS then
                    [
                        #"nfsvers=3"
                        "intr"
                        "nolock"
                        "retry=infinity"
                        "timeo=60"
                    ]
                else
                    [
                        "credentials=${config.sops.secrets."benisuzume/cifs".path}"
                        "x-systemd.automount"
                        "x-systemd.idle-timeout=30"
                        "nofail"
                        "uid=${config.sidonia.userName}"
                        "gid=users"
                        "rw"
                        "rwpidforward"
                        "exec"
                    ]
            )
            ++ [
                (if hardMount then "hard" else "soft")
                "fsc"
            ];
    };
in
{
    services.rpcbind.enable = true;
    boot.supportedFilesystems = [ "nfs" ];
    environment.systemPackages = [ pkgs.cifs-utils ];

    sops.secrets."benisuzume/cifs" = { };

    fileSystems."/mnt/benisuzume" = mntBenisuzume "personal-drive";

    services.cachefilesd.enable = true;
}
