{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:
let
    useNFS = false;
    mntBenisuzumeNFS = name: {
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
    mntBenisuzumeCIFS = name: {
        fsType = "cifs";
        device = "//10.0.4.3/${name}";
        options = [
            "credentials=${config.sops.secrets."benisuzume/cifs".path}"
            "soft"
            "intr"
            "fsc"
        ];
    };
    mntBenisuzume = name: (if useNFS then (mntBenisuzumeNFS name) else (mntBenisuzumeCIFS name));
in
{
    services.rpcbind.enable = true;
    boot.supportedFilesystems = [ "nfs" ];
    environment.systemPackages = [ pkgs.cifs-utils ];

    sops.secrets."benisuzume/cifs" = { };

    fileSystems."/mnt/media" = mntBenisuzume "media";
    fileSystems."/mnt/lancache" = mntBenisuzume "lancache";
    services.cachefilesd = {
        enable = true;
        # TODO: install ssd raid and point cacheDir to it
    };
}
