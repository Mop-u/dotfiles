{
    description = "A simple NixOS flake";
    nixConfig = {
        extra-substituters = [
            "https://hyprland.cachix.org"
            "https://ezkea.cachix.org"
        ];
        extra-trusted-public-keys = [
            "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
            "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
        ];
    };

    inputs = {
        nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
        nixfmt-git.url = "github:NixOS/nixfmt";
        nix-colors.url = "github:misterio77/nix-colors";

        aagl.url = "github:ezKEa/aagl-gtk-on-nix/release-24.11";

        sops-nix = {
            url = "github:Mic92/sops-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        hyprland = {
            url = "https://github.com/hyprwm/Hyprland";
            type = "git";
            submodules = true;
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

        catppuccin-vsc.url = "github:catppuccin/vscode";

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

        veridian-nix = {
            url = "github:Mop-u/veridian-nix";
            #url = "git+file:../veridian-nix";
        };
        
        nonfree-fonts = {
            url = "github:Mop-u/nonfree-fonts";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        naturaldocs = {
            url = "github:Mop-u/naturaldocs-nix";
            #url = "git+file:../naturaldocs-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        slang-lsp = {
            url = "github:Mop-u/slang-lsp-tools-nix";
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
        stextSublimeLinterContribVerilator = {
            url = "github:Mop-u/SublimeLinter-contrib-verilator";
            flake = false;
        };
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
        stextSublimeLinter = {
            url = "github:SublimeLinter/SublimeLinter";
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

    outputs = { self, nixpkgs, ... } @ inputs: {
        nixosConfigurations = nixpkgs.lib.mapAttrs (hostName: v: (nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            modules = [
                ((import ./module.nix) {inherit inputs;})
                (nixpkgs.lib.path.append ./config/target hostName)
            ];
        })) (nixpkgs.lib.filterAttrs (n: v: v == "directory") (builtins.readDir ./config/target));
    };
}
