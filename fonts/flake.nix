{
  description = "A flake giving access to fonts that I use, outside of nixpkgs.";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system:
    let 
      pkgs = nixpkgs.legacyPackages.${system};
    in { 
      defaultPackage = pkgs.symlinkJoin {
        name = "moppu-fonts-0.0.0";
        paths = builtins.attrValues
          self.packages.${system}; # Add font derivation names here
      };
      packages.comic-code = pkgs.stdenvNoCC.mkDerivation {
        name = "comic-code";
        dontConfigure = true;
	nativeBuildInputs = [ pkgs.unzip ];
        src = pkgs.requireFile {
          name = "ILT-230530-b9fd4ab.zip";
          url = "https://fonts.ilovetypography.com/account/orders#ILT-230530-b9fd4ab";
          hash = "sha256-nHX+9TEO8c9TyCSYnV5izHJv3G6mW5p2KAAWqgYNvOg=";
        };
        installPhase = ''
          mkdir -p $out/share/fonts/opentype
          cp ./Comic\ Code/OTF/* $out/share/fonts/opentype/
        '';
        meta = { description = "A monospaced adaptation of the most infamous yet most popular casual font."; };
      };
  });
}
