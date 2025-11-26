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
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

        sidonia = {
            url = "github:Mop-u/sidonia";
            inputs.nixpkgs.follows = "nixpkgs";
            inputs.unstable.follows = "unstable";
        };

        sops-nix = {
            url = "github:Mic92/sops-nix";
            inputs.nixpkgs.follows = "nixpkgs";
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
            inputs.nixpkgs.follows = "nixpkgs";
        };

        quartus = {
            url = "github:Mop-u/nix-quartus";
            #url = "git+file:../nix-quartus";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        nvidia-patch = {
            url = "github:icewind1991/nvidia-patch-nixos";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        nix-minecraft = {
            url = "github:Infinidoge/nix-minecraft";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        steam-fetcher = {
            url = "github:aidalgol/nix-steam-fetcher";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        steam-servers = {
            url = "github:scottbot95/nix-steam-servers";
            inputs.nixpkgs.follows = "nixpkgs";
            inputs.steam-fetcher.follows = "steam-fetcher";
        };
    };

    outputs =
        inputs@{ self, nixpkgs, ... }:
        {
            nixosConfigurations = inputs.sidonia.mkSidonia ./hosts {
                specialArgs = { inherit inputs; };
                modules = [
                    inputs.sops-nix.nixosModules.sops
                ];
            };
        };
}
