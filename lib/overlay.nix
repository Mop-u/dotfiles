{config}:
final: prev: let cfg = config.sidonia; in { 
    lib = prev.lib or {} // { 

        decToHex256 = dec: prev.lib.toHexString (builtins.floor (dec*255.0));

        capitalize = str: let
            chars = prev.lib.stringToCharacters str;
        in prev.lib.concatStrings ([(prev.lib.toUpper (builtins.head chars))] ++ (builtins.tail chars));
    
        # https://stackoverflow.com/questions/54504685/nix-function-to-merge-attributes-records-recursively-and-concatenate-arrays
        recursiveMerge = attrList: let
            f = attrPath: with builtins;
                zipAttrsWith (name: values:
                    # return if there is only one item for that attribute
                    if tail values == []
                        then head values
                    # merge and return when we hit lists
                    else if all isList values
                        then prev.lib.lists.unique (concatLists values)
                    # go deeper on attributes
                    else if all isAttrs values
                        then f (attrPath ++ [name]) values
                    # we can't merge unless they are lists so just use the last value
                    #else lib.lists.last values
                    else prev.lib.assertMsg false ''
                        Configuration collision at multiple definitions of ${prev.lib.concatStringsSep "." attrPath}
                               Can't merge the following values: ${toString values}
                               If you expected your values to be merged into a list, wrap them in square brackets to allow list concatenation.
                    ''
                );
        in f [] attrList;

        lsFiles = path: prev.lib.mapAttrsToList (n: v: (prev.lib.path.append path n)) (prev.lib.filterAttrs (n: v: v == "regular") (builtins.readDir path));
        
        isInstalled = package: builtins.elem package.pname (builtins.catAttrs "pname" (
            config.environment.systemPackages ++ config.users.users.${cfg.userName}.packages ++ config.home-manager.users.${cfg.userName}.home.packages
        ));

        home = {
            applications = "/home/${cfg.userName}/.nix-profile/share/applications";
            autostart = "/home/${cfg.userName}/.config/autostart";
        };
    };
}