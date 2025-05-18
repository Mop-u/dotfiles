{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:
let
    cfg = config.sidonia;
    builderName = "tsumugibld";
    identityFile = "/home/${cfg.userName}/.ssh/id_ed25519"; # /root/.ssh/nixremote
in
{
    options.sidonia.services.remoteBuilders.enable = lib.mkEnableOption "Enable distributed nix builds";

    config = lib.mkIf cfg.services.remoteBuilders.enable {
        programs.ssh = {
            knownHosts = {
                ${builderName} = {
                    extraHostNames = [
                        "tsumugi.local"
                        "10.0.4.2"
                    ];
                    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIBidxqGI8eFmemPDR2FAGpApxR4tXgSD6m893JchS2+";
                };
            };
            extraConfig = ''
                Host ${builderName}
                    User builder
                    Hostname tsumugi.local
                    IdentitiesOnly yes
                    IdentityFile ${identityFile}
            '';
        };
    };
}
