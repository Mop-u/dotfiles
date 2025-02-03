{self, inputs}:
rec {
    setTarget = override: rec {

        lib = let 
            config = self.nixosConfigurations.${override.hostName}.config; # get the host's config
            target = setTarget override; # beware infinite recursion!
            lib = inputs.nixpkgs.lib;
        in (import ./lib.nix) {inherit target config lib;};

        hostName  = override.hostName;
        userName  = override.userName;
        stateVer  = override.stateVer;
        system    = override.system or "x86_64-linux";


        # monitors.*.name: name of monitor (see hyprland wiki)
        # monitors.*.args: resolution/scaling/positioning args (see hyprland wiki)
        monitors = builtins.map ( monitor: {
            name = monitor.name;
            args = monitor.args;
            enable  = builtins.concatStringsSep "," [monitor.name monitor.args];
            disable = builtins.concatStringsSep "," [monitor.name "disable"];
        })((override.monitors or []) ++ [{name="";args="highres,auto,1";}]);


        # isLaptop: bool - if this is enabled, the first monitor in the list is disabled on lid close.
        isLaptop = override.isLaptop or false;

        # graphics.legacyGpu: bool # set this to true for OpenGL ES 2 support
        # graphics.headless:  bool # set this to true to disable the desktop environment
        graphics = {
            legacyGpu = override.graphics.legacyGpu or false;
            headless = override.graphics.headless or false;
        };

        # style.catppuccin.flavor: latte/frappe/macchiato/mocha
        # style.catppuccin.accent: see all available colours at https://catppuccin.com/palette (or check catppuccin.nix)
        # style.cursorSize:        integer
        style = {
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
        
        # window.borderSize: integer
        # window.rounding:   integer
        # window.opacity:    2-digit hexadecimal string
        # window.float.w:    integer
        # window.float.h:    integer
        window = {
            # define default width/height of a spawned floating window
            float = rec {
                w = (override.window.float.w or "896") + "";
                h = (override.window.float.h or "504") + "";
                wh = w + " " + h;
                onCursor = "move onscreen cursor -50% -50%";
            };
            borderSize = (override.window.borderSize or "2") + "";
            rounding = (override.window.rounding or "10") + "";
            opacity = rec {
                hex = override.window.opacity or "d9";
                dec = ((inputs.nix-colors.lib.conversions.hexToDec hex)+0.0) / 255.0;
            };
        };

        # text.smallTermFont:    bool
        # text.comicCode.enable: bool
        text = {
            smallTermFont = override.text.smallTermFont or false;
            comicCode = {
                enable  = override.text.comicCode.enable or false;
                package = inputs.nonfree-fonts.packages.${system}.comic-code;
                name    = if text.comicCode.enable then "Comic Code" else "ComicShannsMono Nerd Font";
            };
        };

        # input.sensitivity:  float range from -1.0 to +1.0
        # input.accelProfile: adaptive/flat/custom https://wiki.hyprland.org/Configuring/Variables/#custom-accel-profiles
        # input.keyLayout:    keyboard layout string
        input = {
            sensitivity  = override.input.sensitivity or 0.0;
            accelProfile = override.input.accelProfile or "flat";
            keyLayout    = override.input.keyLayout or "us";
        };

        # config.graphical.optional: list of .nix filenames
        # config.headless.optional: list of .nix filenames

        modules = [
            inputs.catppuccin.nixosModules.catppuccin
            inputs.home-manager.nixosModules.home-manager
            inputs.lancache.nixosModules.dns
            inputs.lancache.nixosModules.cache
            inputs.aagl.nixosModules.default
            inputs.sops-nix.nixosModules.sops
            inputs.nix-minecraft.nixosModules.minecraft-servers
            {
                home-manager.users.${override.userName}.imports = [
                    inputs.catppuccin.homeManagerModules.catppuccin
                ];
            }
            ../config/headless/default.nix
            (if (!graphics.headless) then ../config/graphical/default.nix else {})
        ];
        # use builtins.getAttr to assert that all the user-input target config options exist
    };
}