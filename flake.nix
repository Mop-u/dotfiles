{
    description = "A simple NixOS flake";
    nixConfig = {
        extra-substituters = [
            "https://hyprland.cachix.org"
        ];
        extra-trusted-public-keys = [
            "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        ];
    };
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        catppuccin = {
            url = "github:catppuccin/nix";
        };
        moppu-fonts = {
            url = "github:Mop-u/nonfree-fonts";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        aagl = { 
            url = "github:ezKEa/aagl-gtk-on-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = { self, nixpkgs, home-manager, catppuccin, moppu-fonts, aagl, hyprland, ... } @ inputs:
        let
            hostname = "kaoru";
            username = "hazama";
        in { nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = { inherit inputs; };
            modules = [
                catppuccin.nixosModules.catppuccin
                home-manager.nixosModules.home-manager
                {
                    home-manager.users.${username} = {
                        imports = [ catppuccin.homeManagerModules.catppuccin ];
                    };
                }
                ./configuration.nix
                {
                    _module.args = { inherit inputs; };

                    #nix.settings = aagl.nixConfig; # set up cachix

                    imports = [
                        aagl.nixosModules.default
                    ];
                    
                    programs = {
                        anime-game-launcher.enable = true; # genshin
                        sleepy-launcher.enable = true; # zzz

                        honkers-railway-launcher.enable = false;
                        honkers-launcher.enable = false;
                        
                        wavey-launcher.enable = false;             # Not currently playable
                        anime-games-launcher.enable = false; # Not for regular use
                        anime-borb-launcher.enable = false;    # Not actively maintained
                    };
                }
                ./desktop-environment.nix
            ];
        };
    };
}
