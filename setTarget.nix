{self, inputs}:
rec {
    setTarget = override: rec {

        hostName  = override.hostName;
        userName  = override.userName;
        stateVer  = override.stateVer;
        system    = override.system or "x86_64-linux";

        legacyGpu = override.legacyGpu or false; # set this to true for OpenGL ES 2 support

        helper = let 
            config = self.nixosConfigurations.${override.hostName}.config; # get the host's config
            target = setTarget override; # beware infinite recursion!
        in (import ./helper.nix) {inherit target config;};

        modules = [
            inputs.catppuccin.nixosModules.catppuccin
            inputs.home-manager.nixosModules.home-manager
            inputs.aagl.nixosModules.default
            inputs.nur.nixosModules.nur
            {
                home-manager.users.${override.userName}.imports = [
                    inputs.catppuccin.homeManagerModules.catppuccin
                    inputs.nur.hmModules.nur
                ];
            }
            ./configuration.nix
            ./desktop-environment/default.nix
            ./target/${override.hostName}/hardware-configuration.nix
        ];

        style = {
            # style.catppuccin.flavor: latte/frappe/macchiato/mocha
            # style.catppuccin.accent: see all available colours at https://catppuccin.com/palette (or check catppuccin.nix)
            # style.cursorSize:        integer
            catppuccin = let
                flavor = override.style.catppuccin.flavor or "frappe"; # 
                accent = override.style.catppuccin.accent or "mauve";  # 
                result = (import ./catppuccin.nix).catppuccin.${flavor} // {
                    flavor = flavor;
                    accent = accent;
                    highlight = result.${accent};
                };
            in result;
            cursorSize = {
                gtk  = (override.style.cursorSize or "30") + "";
                hypr = (override.style.cursorSize or "30") + "";
            };
        };
        
        window = {
            # window.borderSize: integer
            # window.rounding:   integer
            # window.opacity:    2-digit hexadecimal string
            borderSize = (override.window.borderSize or "2") + "";
            rounding = (override.window.rounding or "10") + "";
            opacity = rec {
                hex = override.window.opacity or "d9";
                dec = ((inputs.nix-colors.lib.conversions.hexToDec hex)+0.0) / 255.0;
            };
        };

        text = {
            # text.smallTermFont:    bool
            # text.comicCode.enable: bool
            smallTermFont = override.text.smallTermFont or false;
            comicCode = {
                enable  = override.text.comicCode.enable or false;
                package = inputs.nonfree-fonts.packages.${system}.comic-code;
                name    = if text.comicCode.enable then "Comic Code" else "ComicShannsMono Nerd Font";
            };
        };

        input = {
            # input.sensitivity:  float range from -1.0 to +1.0
            # input.accelProfile: adaptive/flat/custom https://wiki.hyprland.org/Configuring/Variables/#custom-accel-profiles
            # input.keyLayout:    keyboard layout string
            sensitivity  = override.input.sensitivity or 0.0;
            accelProfile = override.input.accelProfile or "flat";
            keyLayout    = override.input.keyLayout or "us";
        };

        # use builtins.getAttr to assert that all the user-input target config options exist
    };
}