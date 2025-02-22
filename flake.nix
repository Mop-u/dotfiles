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
        #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

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
        catppuccin = {
            url = "github:catppuccin/nix";
        };

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
            url = "github:Mop-u/nix-quartus/ux";
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
                    isLaptop = true;
                    monitors = [{
                        name = "eDP-1";
                        args = "2560x1600@165.00400,1920x0,1.333333,bitdepth,10";
                    }{
                        name = "desc:Lenovo Group Limited P40w-20";
                        args = "5120x2160@74.97900,-4800x-400,1.066667,bitdepth,8";
                    }{
                        name = "desc:BNQ ZOWIE XL LCD JAG03521SL0";
                        args = "1920x1080@60.00,0x0,1.0,bitdepth,8";
                    }];
                };
                yure = setTarget {
                    hostName = "yure";
                    userName = "shinatose";
                    stateVer = "24.05";
                    graphics.legacyGpu = true;
                    text.smallTermFont = false;
                    style.catppuccin.flavor = "mocha";
                    style.catppuccin.accent = "mauve";
                    text.comicCode.enable = true;
                    input.sensitivity = -0.1;
                    input.keyLayout = "gb";
                    isLaptop = true;
                    monitors = [{
                        name = "LVDS-1";
                        args = "highres,0x0,1";
                    }];
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
        in inputs.nixpkgs.lib.mapAttrs (n: target: (inputs.nixpkgs.lib.nixosSystem {
            system = target.system;
            specialArgs = {inherit inputs target;};
            modules = target.modules;
        })) targets;
    };
}
