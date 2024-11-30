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
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        nix-colors.url = "github:misterio77/nix-colors";

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

        waybar = {
            url = "github:Alexays/Waybar";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        hyprswitch = {
            url = "github:h3rmt/hyprswitch/release";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        catppuccin = {
            url = "github:catppuccin/nix";
        };
        aagl = { 
            url = "github:ezKEa/aagl-gtk-on-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nonfree-fonts = {
            url = "github:Mop-u/nonfree-fonts";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        naturaldocs = {
            url = "github:Mop-u/naturaldocs-nix";
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

    outputs = { self, ... } @ inputs: {
        nixosConfigurations = let
            #TODO: add default package definitions etc. here as part of setTarget bringup
            setTarget = (import ./lib/setTarget.nix {inherit self inputs;}).setTarget;
            targets = {
                kaoru = setTarget {
                    hostName = "kaoru";
                    userName = "hazama";
                    stateVer = "23.11";
                    style.catppuccin.flavor = "macchiato";
                    style.catppuccin.accent = "mauve";
                    text.comicCode.enable = true;
                };
                yure = setTarget {
                    hostName = "yure";
                    userName = "shinatose";
                    stateVer = "24.05";
                    graphics.legacyGpu = true;
                    text.smallTermFont = true;
                    style.catppuccin.flavor = "mocha";
                    style.catppuccin.accent = "sky";
                    text.comicCode.enable = true;
                    input.sensitivity = -0.1;
                    input.keyLayout = "gb";
                };
                tsumugi = setTarget {
                    hostName = "tsumugi";
                    userName = "shiraui";
                    stateVer = "24.05";
                    style.catppuccin.flavor = "macchiato";
                    style.catppuccin.accent = "teal";
                    graphics.headless = true;
                };
            };
        in {
            kaoru = let 
                target = targets.kaoru;
            in inputs.nixpkgs.lib.nixosSystem {
                system = target.system;
                specialArgs = { 
                    inherit inputs;
                    inherit target;
                };
                modules = target.modules;
            };
            yure = let 
                target = targets.yure;
            in inputs.nixpkgs.lib.nixosSystem {
                system = target.system;
                specialArgs = {
                    inherit inputs;
                    inherit target;
                };
                modules = target.modules;
            };
            tsumugi = let
                target = targets.tsumugi;
            in inputs.nixpkgs.lib.nixosSystem {
                system = target.system;
                specialArgs = {
                    inherit inputs;
                    inherit target;
                };
                modules = target.modules;
            };
        };
    };
}
