{target,config}:
{
    isInstalled = package: builtins.elem package.pname (builtins.catAttrs "pname" (
            config.environment.systemPackages ++ config.users.users.${target.userName}.packages ++ config.home-manager.users.${target.userName}.home.packages
    ));
}