{
    description = "A simple NixOS flake";
    nixConfig = {
        extra-substituters = [
            "https://ezkea.cachix.org"
        ];
        extra-trusted-public-keys = [
            "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
        ];
    };

    inputs = {
        unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
        nixfmt-git.url = "github:NixOS/nixfmt";
        nix-colors.url = "github:misterio77/nix-colors";

        aagl.url = "github:ezKEa/aagl-gtk-on-nix/release-24.11";

        sops-nix = {
            url = "github:Mic92/sops-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        hyprswitch = {
            url = "github:h3rmt/hyprswitch/release";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        home-manager = {
            url = "github:nix-community/home-manager/release-24.11";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        catppuccin.url = "github:catppuccin/nix";

        lancache-domains = {
            url = "github:uklans/cache-domains";
            flake = false;
        };
        lancache-monolithic = {
            url = "github:lancachenet/monolithic";
            flake = false;
        };
        lancache = {
            url = "github:Mop-u/nix-lancache";
            inputs.cache-domains.follows = "lancache-domains";
            inputs.monolithic.follows = "lancache-monolithic";
        };
        nonfree-fonts = {
            url = "github:Mop-u/nonfree-fonts";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        quartus = {
            url = "github:Mop-u/nix-quartus";
            #url = "git+file:../nix-quartus";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nix-minecraft = {
            url = "github:Infinidoge/nix-minecraft";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

        # sublime text packages
        stextPackageControl = {
            url = "github:wbond/package_control";
            flake = false;
        };
        stextLSP = {
            url = "github:sublimelsp/LSP";
            flake = false;
        };
        stextNix = {
            url = "github:wmertens/sublime-nix";
            flake = false;
        };
        stextCatppuccin = {
            url = "github:catppuccin/sublime-text";
            flake = false;
        };
        stextSystemVerilog = {
            url = "github:TheClams/SystemVerilog";
            flake = false;
        };
        stextHooks = {
            url = "github:twolfson/sublime-hooks";
            flake = false;
        };

        # plex packages
        plexHama = {
            url = "github:ZeroQI/Hama.bundle";
            flake = false;
        };
        plexASS = {
            url = "github:ZeroQI/Absolute-Series-Scanner";
            flake = false;
        };

        # get up-to-date kmscon version
        kmscon = {
            url = "github:Aetf/kmscon/develop";
            flake = false;
        };
        libtsm = {
            url = "github:Aetf/libtsm/develop";
            flake = false;
        };

        # get up-to-date magnetic-catppuccin-gtk
        magnetic-catppuccin-gtk = {
            url = "github:Fausto-Korpsvart/Catppuccin-GTK-Theme";
            flake = false;
        };

        #goxlr-utility-ui = {
        #    url = "git+file:../goxlr-utility-ui-nix";
        #};
    };

    outputs =
        { self, nixpkgs, ... }@inputs:
        let
            inherit (nixpkgs) lib;
            mkConfig =
                hostName:
                (lib.nixosSystem {
                    specialArgs = { inherit inputs; };
                    modules = [
                        ((import ./module.nix) { inherit inputs; })
                        (lib.path.append ./hosts hostName)
                    ];
                });
            hosts = lib.filterAttrs (n: v: v == "directory") (builtins.readDir ./hosts);
        in
        {
            nixosConfigurations = lib.mapAttrs (n: v: (mkConfig n)) hosts;
        };
}
