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
        hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
        nur.url = "github:nix-community/NUR";
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

    outputs = { self, ... } @ inputs:
        let
            hostname = "kaoru";
            username = "hazama";
        in { nixosConfigurations.${hostname} = inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = { inherit inputs; };
            modules = [
                inputs.catppuccin.nixosModules.catppuccin
                inputs.home-manager.nixosModules.home-manager
                inputs.aagl.nixosModules.default
                inputs.nur.nixosModules.nur
                {home-manager.users.${username}.imports = [
                    inputs.catppuccin.homeManagerModules.catppuccin
                    inputs.nur.hmModules.nur
                ];}
                ./hardware-configuration.nix
                ./configuration.nix
                ./desktop-environment.nix
            ];
        };
    };
}
