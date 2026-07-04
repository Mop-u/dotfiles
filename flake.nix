{
  description = "A simple NixOS flake";

  inputs = {
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
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
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    {
      nixosConfigurations = inputs.sidonia.mkSidonia ./hosts {
        specialArgs = { inherit inputs; };
        modules = [
          inputs.sops-nix.nixosModules.sops
          ./common
        ];
      };
    };
}
