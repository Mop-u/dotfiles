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
        systems.url = "github:nix-systems/default-linux";
        nur.url = "github:nix-community/NUR";
        nix-colors.url = "github:misterio77/nix-colors";

        # Make sure hyprland is using the latest sources (hyprland's flake.lock lags behind sometimes)
        hyprutils = {
            url = "github:hyprwm/hyprutils";
            inputs.nixpkgs.follows = "nixpkgs";
            inputs.systems.follows = "systems";
        };
        hyprwayland-scanner = {
            url = "github:hyprwm/hyprwayland-scanner";
            inputs.nixpkgs.follows = "nixpkgs";
            inputs.systems.follows = "systems";
        };
        hyprland-protocols = {
            url = "github:hyprwm/hyprland-protocols";
            inputs.nixpkgs.follows = "nixpkgs";
            inputs.systems.follows = "systems";
        };
        hyprlang = {
            url = "github:hyprwm/hyprlang";
            inputs.nixpkgs.follows = "nixpkgs";
            inputs.systems.follows = "systems";
            inputs.hyprutils.follows = "hyprutils";
        };
        hyprcursor = {
            url = "github:hyprwm/hyprcursor";
            inputs.nixpkgs.follows = "nixpkgs";
            inputs.systems.follows = "systems";
            inputs.hyprlang.follows = "hyprlang";
        };
        xdph = {
            url = "github:hyprwm/xdg-desktop-portal-hyprland";
            inputs.nixpkgs.follows = "nixpkgs";
            inputs.systems.follows = "systems";
            inputs.hyprlang.follows = "hyprlang";
            inputs.hyprland-protocols.follows = "hyprland-protocols";
        };
        aquamarine = {
            url = "github:hyprwm/aquamarine";
            inputs.nixpkgs.follows = "nixpkgs";
            inputs.systems.follows = "systems";
            inputs.hyprutils.follows = "hyprutils";
            inputs.hyprwayland-scanner.follows = "hyprwayland-scanner";
        };
        hyprland = {
            url = "https://github.com/hyprwm/Hyprland";
            type = "git";
            submodules = true;
            inputs.nixpkgs.follows = "nixpkgs";
            inputs.systems.follows = "systems";
            inputs.hyprlang.follows = "hyprlang";
            inputs.hyprutils.follows = "hyprutils";
            inputs.hyprcursor.follows = "hyprcursor";
            inputs.aquamarine.follows = "aquamarine";
            inputs.hyprwayland-scanner.follows = "hyprwayland-scanner";
            inputs.xdph.follows = "xdph";
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
        spacedrive = {
            url = "github:Mop-u/spacedrive-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = { self, ... } @ inputs: {
        nixosConfigurations = let
            setTarget = override: rec {
                hostName  = override.hostName;
                userName  = override.userName;
                stateVer  = override.stateVer;
                system    = override.system    or "x86_64-linux";
                legacyGpu = override.legacyGpu or false;
                smallTermFont = override.smallTermFont or false;
                modules   = override.modules   or [
                    inputs.catppuccin.nixosModules.catppuccin
                    inputs.home-manager.nixosModules.home-manager
                    inputs.aagl.nixosModules.default
                    inputs.nur.nixosModules.nur
                    {home-manager.users.${override.userName}.imports = [
                        inputs.catppuccin.homeManagerModules.catppuccin
                        inputs.nur.hmModules.nur
                    ];}
                    ./configuration.nix
                    ./desktop-environment/default.nix
                    ./target/${override.hostName}/hardware-configuration.nix
                ];
                catppuccin = let
                    flavor = override.catppuccin.flavor or "frappe"; # latte/frappe/macchiato/mocha
                    accent = override.catppuccin.accent or "mauve";  # see all available colours at https://catppuccin.com/palette (or check catppuccin.nix)
                    result = (import ./catppuccin.nix).catppuccin.${flavor} // {
                        flavor = flavor;
                        accent = accent;
                        highlight = result.${accent};
                    };
                in result;
                comicCode = rec {
                    enable  = override.comicCode.enable or false;
                    package = override.comicCode.package or inputs.nonfree-fonts.packages.${system}.comic-code;
                    name    = if comicCode.enable then "Comic Code" else "ComicShannsMono Nerd Font";
                };
            };
            targets = {
                kaoru = setTarget {
                    hostName = "kaoru";
                    userName = "hazama";
                    stateVer = "23.11";
                    catppuccin.flavor = "frappe";
                    catppuccin.accent = "mauve";
                    comicCode.enable = true;
                };
                yure = setTarget {
                    hostName = "yure";
                    userName = "shinatose";
                    stateVer = "24.05";
                    legacyGpu = true;
                    smallTermFont = true;
                    catppuccin.flavor = "mocha";
                    catppuccin.accent = "sky";
                    comicCode.enable = true;
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
        };
    };
}
