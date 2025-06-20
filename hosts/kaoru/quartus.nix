{
    config,
    pkgs,
    inputs,
    lib,
    ...
}:
{
    imports = [
        inputs.quartus.nixosModules.quartus
    ];
    programs.quartus = {
        enable = true;
        lite = {
            enable = true;
            version = 23;
            devices = [ "cyclonev" ];
        };
        pro = {
            enable = true;
            version = 24;
            devices = [ "cyclone10gx" ];
        };
    };
}
