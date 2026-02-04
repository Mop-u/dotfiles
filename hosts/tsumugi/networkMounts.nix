{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:
let
    hardMount = true;
    mntBenisuzume = name: {
        fsType = "nfs";
        device = "10.0.4.3:/var/nfs/shared/${name}";
        options = [
            "nolock"
            "hard"
            "async"
            "fsc"
            "noatime"
            "nodiratime"
        ];
    };
in
{
    services.rpcbind.enable = true;
    boot.supportedFilesystems = [ "nfs" ];
    environment.systemPackages = [ pkgs.cifs-utils ];

    sops.secrets."benisuzume/cifs" = { };

    fileSystems."/mnt/media" = mntBenisuzume "media";
    fileSystems."/mnt/gameservers" = mntBenisuzume "gameservers";
    fileSystems."/mnt/lancache" = mntBenisuzume "lancache";

    services.cachefilesd = {
        enable = true;
        cacheDir = "/mnt/cache/fscache";
    };
}
