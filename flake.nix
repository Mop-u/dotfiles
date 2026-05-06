{
    description = "A simple NixOS flake";

    inputs = {
        unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
        moppkgs.url = "github:Mop-u/moppkgs";

        sidonia = {
            url = "github:Mop-u/sidonia";
            inputs.nixpkgs.follows = "nixpkgs";
            inputs.unstable.follows = "unstable";
            inputs.moppkgs.follows = "moppkgs";
        };

        sops-nix = {
            url = "github:Mic92/sops-nix";
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
