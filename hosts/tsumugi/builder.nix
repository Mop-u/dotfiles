{
    config,
    pkgs,
    inputs,
    lib,
    ...
}:
{
    users.users.builder = {
        isNormalUser = true;
        openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGPu3ruHZ4DEtjajBbIXDh1XoTYkI/7moYDZn1CcKOWU root@kaoru"
        ];
    };
    services.openssh.settings.AllowUsers = [ "builder" ];
}
