{ inputs, config, pkgs, lib, target, ... }: let

    #todo: use builtins.readDir to get all add-in modules from a directory
    modules = builtins.map (module: import module {inherit inputs config pkgs lib target;})[
        ./bemenu.nix
        ./discord.nix
        ./dunst.nix
        ./foot.nix
        ./hyprland.nix
        ./hyprswitch.nix
        ./misc.nix
        ./vesktop.nix
        ./waybar.nix
    ];
    # https://stackoverflow.com/questions/54504685/nix-function-to-merge-attributes-records-recursively-and-concatenate-arrays
    recursiveMerge = attrList:
        let f = attrPath: with builtins;
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

in recursiveMerge modules
