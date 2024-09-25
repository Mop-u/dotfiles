{target,config,lib}:
{
    isInstalled = package: builtins.elem package.pname (builtins.catAttrs "pname" (
            config.environment.systemPackages ++ config.users.users.${target.userName}.packages ++ config.home-manager.users.${target.userName}.home.packages
    ));
    capitalize = str: let
        chars = lib.strings.stringToCharacters str;
    in lib.strings.concatStrings ([(lib.strings.toUpper (builtins.head chars))] ++ (builtins.tail chars));
}
