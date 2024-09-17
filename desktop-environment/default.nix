{ inputs, config, pkgs, lib, target, ... }:
{

    nixpkgs.overlays = [
        (final: prev: {
            hyprland = (inputs.hyprland.packages.${pkgs.system}.hyprland.override{legacyRenderer=target.legacyGpu;});
        })
    ];

    security = {
        pam.services.hyprlock = {};
        pam.services.sddm.enableGnomeKeyring = true;
        polkit.enable = true;
    };
    xdg = {
        autostart.enable = true;
        portal = {
            extraPortals = [
                pkgs.xdg-desktop-portal-gnome
            ];
        };
    };

    services.displayManager = {
        sddm.enable = true;
        sddm.wayland.enable = true;
        sddm.package = pkgs.kdePackages.sddm;
        autoLogin.enable = true;
        autoLogin.user = target.userName;
        defaultSession = "hyprland";
    };

    services = {
        blueman.enable = true;
        goxlr-utility.enable = true;
        gvfs.enable = true; # Mount, trash, and other functionalities
        tumbler.enable = true; # Thumbnail support for images
    };

    nixpkgs.config.permittedInsecurePackages = [
        "openssl-1.1.1w"  # for sublime4 & sublime-merge :(
    ]; 

    # enable virtual camera for OBS
    boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
    boot.extraModprobeConfig = ''
        options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
    '';

    programs = {
        seahorse.enable = true;
        hyprland = {
            enable = true;
            portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
        };
        steam = {
            enable = true;
            protontricks.enable = true;
            extest.enable = true;
            gamescopeSession.enable = true;
        };
        xfconf.enable = true; # for remembering thunar preferences etc.

        anime-game-launcher.enable = !target.legacyGpu; # genshin
        sleepy-launcher.enable = !target.legacyGpu; # zzz

        honkers-railway-launcher.enable = false;
        honkers-launcher.enable = false;
        
        wavey-launcher.enable = false;       # Not currently playable
        anime-games-launcher.enable = false; # Not for regular use
        anime-borb-launcher.enable = false;  # Not actively maintained
    };

    home-manager = {
        useGlobalPkgs = true;
        backupFileExtension = "backup";
    };

    home-manager.users.${target.userName} = let

        #todo: use builtins.readDir to get all add-in modules from a directory
        modules = builtins.map (module: import module {inherit inputs config pkgs lib target;})[
            ./bemenu.nix
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

    in recursiveMerge modules;
}
