{ inputs, config, pkgs, lib, target, ... }:
{
    fileSystems."/mnt/media" = {
        fsType = "nfs";
        device = "10.0.4.3:/var/nfs/shared/media";
        options = [
            "nfsvers=3"
            "hard"
            "intr"
            "nolock"
        ];
    };
}