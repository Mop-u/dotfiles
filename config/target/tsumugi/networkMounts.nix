{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:
let
    mntBenisuzume = name: {
        fsType = "nfs";
        device = "10.0.4.3:/var/nfs/shared/${name}";
        options = [
            "nfsvers=3"
            "hard" # hard mount
            "intr"
            "nolock" # no file locking
            "fsc" # enable caching with cachefilesd
        ];
    };
in
{
    fileSystems."/mnt/media" = mntBenisuzume "media";
    fileSystems."/mnt/lancache" = mntBenisuzume "lancache";

    services.cachefilesd = {
        enable = true;
        # TODO: install ssd raid and point cacheDir to it
    };
}
