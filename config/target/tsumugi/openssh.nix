{ inputs, config, pkgs, lib, target, ... }:

{
    # Enable the OpenSSH daemon.
    services.openssh = {
        enable = true;
        ports = [ 22 ];
        settings = {
            PasswordAuthentication = false;
            AllowUsers = null;
            UseDns = false;
            X11Forwarding = false;
            PermitRootLogin = "no";
        };
    };

    users.users.${target.userName}.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINfNV3Z/LI/4ItskdADIC4JWqfW3Wae4TRK/Ahos5TgB hazama@kaoru"
    ];

}
