{ inputs, config, pkgs, lib, target, ... }: let
    mntBenisuzume = name: {
        fsType = "nfs";
        device = "10.0.4.3:/var/nfs/shared/${name}";
        options = [
            "nfsvers=3"
            "hard"
            "intr"
            "nolock"
        ];
    };
in {
    fileSystems."/mnt/media"    = mntBenisuzume "media";
    fileSystems."/mnt/lancache" = mntBenisuzume "lancache";
}