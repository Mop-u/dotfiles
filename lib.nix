{target,config,lib}:
{
    isInstalled = package: builtins.elem package.pname (builtins.catAttrs "pname" (
            config.environment.systemPackages ++ config.users.users.${target.userName}.packages ++ config.home-manager.users.${target.userName}.home.packages
    ));

    capitalize = str: let
        chars = lib.strings.stringToCharacters str;
    in lib.strings.concatStrings ([(lib.strings.toUpper (builtins.head chars))] ++ (builtins.tail chars));

    # https://stackoverflow.com/questions/54504685/nix-function-to-merge-attributes-records-recursively-and-concatenate-arrays
    recursiveMerge = attrList: let
        f = attrPath: with builtins;
            zipAttrsWith (name: values:
                # return if there is only one item for that attribute
                if tail values == []
                    then head values
                # merge and return when we hit lists
                else if all isList values
                    then lib.lists.unique (concatLists values)
                # go deeper on attributes
                else if all isAttrs values
                    then f (attrPath ++ [name]) values
                # we can't merge unless they are lists so just use the last value
                #else lib.lists.last values
                else lib.asserts.assertMsg false ''
                    Configuration collision at multiple definitions of ${lib.strings.concatStringsSep "." attrPath}
                           Can't merge the following values: ${toString values}
                           If you expected your values to be merged into a list, wrap them in square brackets to allow list concatenation.
                ''
            );
    in f [] attrList;

    home.applications = "/home/${target.userName}/.nix-profile/share/applications";
    home.autostart = "/home/${target.userName}/.config/autostart";
}
