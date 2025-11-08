{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:
let
    useNFS = true;
    hardMount = true;
    mntBenisuzume = name: {
        fsType = if useNFS then "nfs" else "cifs";
        device = if useNFS then "10.0.4.3:/var/nfs/shared/${name}" else "//10.0.4.3/${name}";
        options =
            (
                if useNFS then
                    [
                        "nolock"
                    ]
                else
                    [ "credentials=${config.sops.secrets."benisuzume/cifs".path}" ]
            )
            ++ (
                if hardMount then
                    [
                        "hard"
                        "intr"
                    ]
                else
                    [ "soft" ]
            )
            ++ [
                "intr"
                "fsc"
                "retry=infinity"
                "timeo=60"
            ];
    };
in
{
    services.rpcbind.enable = true;
    boot.supportedFilesystems = [ "nfs" ];
    environment.systemPackages = [ pkgs.cifs-utils ];

    sops.secrets."benisuzume/cifs" = { };

    fileSystems."/mnt/media" = mntBenisuzume "media";
    fileSystems."/mnt/lancache" = mntBenisuzume "lancache";
    fileSystems."/mnt/gameservers" = mntBenisuzume "gameservers";

    services.cachefilesd = {
        enable = true;
        cacheDir = "/mnt/cache/fscache";
    };
}
