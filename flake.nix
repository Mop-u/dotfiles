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

    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: {
    nixosConfigurations = inputs.sidonia.mkSidonia ./hosts {
      specialArgs = { inherit inputs; };
      modules = [ ./common ];
    };
  };
}
