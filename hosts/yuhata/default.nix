{
    config,
    pkgs,
    inputs,
    lib,
    ...
}:
{
    imports = [ ./os ];
    home-manager.users.${config.sidonia.userName}.imports = [ ./home ];
    sops = {
        defaultSopsFile = ../../secrets/secrets.yaml;
        defaultSopsFormat = "yaml";
        age.keyFile = "/home/midorikawa/.config/sops/age/keys.txt";
    };
}
