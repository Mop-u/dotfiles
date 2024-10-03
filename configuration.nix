# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, lib, target, ... }:
{
    boot.initrd.systemd.enable = true;

    networking.hostName = target.hostName;

    nix.gc.automatic = false;

    catppuccin = {
        enable = true;
        accent = target.style.catppuccin.accent;
        flavor = target.style.catppuccin.flavor;
    };

    # Enable Graphics
    hardware.graphics = {
        enable = true;
        enable32Bit = true;
    };

    # Enable sound
    security.rtkit.enable = true;
    services.pipewire = {
        enable = true;
        audio.enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
        wireplumber.enable = true;
    };

    # use rust based switch-to-configuration-ng
    system.switch = {
        enable = false;
        enableNg = true;
    };

    services.fstrim.enable = true;
    services.dbus.implementation = "broker";
    services.irqbalance.enable = true;

    # Enable networking
    networking.networkmanager = {
        enable = true;
        wifi = {
            backend = "iwd";
            powersave = true;
        };
        dns = "systemd-resolved";
    };
    networking.nftables.enable = true;
    networking.firewall.enable = true;


    # Enable local service discovery
    networking.firewall.allowedUDPPorts = [5353];
    services.resolved = {
        enable = true;
	    llmnr = "true"; # true/false/resolve
	    dnsovertls = "opportunistic";
    };


    # Enable bluetooth
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;

    # Set your time zone.
    time.timeZone = "Europe/Dublin";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_GB.UTF-8";

    i18n.extraLocaleSettings = {
        LC_ADDRESS        = "en_IE.UTF-8";
        LC_IDENTIFICATION = "en_IE.UTF-8";
        LC_MEASUREMENT    = "en_IE.UTF-8";
        LC_MONETARY       = "en_IE.UTF-8";
        LC_NAME           = "en_IE.UTF-8";
        LC_NUMERIC        = "en_IE.UTF-8";
        LC_PAPER          = "en_IE.UTF-8";
        LC_TELEPHONE      = "en_IE.UTF-8";
        LC_TIME           = "en_IE.UTF-8";
    };

    console.keyMap = target.input.keyLayout;

    # more feature-rich tty
    # https://github.com/Aetf/kmscon
    nixpkgs.overlays = [
        (final: prev: {
            kmscon = (prev.kmscon.overrideAttrs{
                src = inputs.kmscon;
                buildInputs = with pkgs; [
                    util-linux
                    check
                    libGLU
                    libGL
                    libdrm
                    # https://github.com/Aetf/kmscon/issues/64
                    (libtsm.overrideAttrs{src=inputs.libtsm;})
                    libxkbcommon
                    pango
                    pixman
                    systemd
                    mesa
                ];

                patches = [./kmscon-systemd-path.patch];

                env.NIX_CFLAGS_COMPILE = "-O" # _FORTIFY_SOURCE requires compiling with optimization (-O)
                    # https://github.com/Aetf/kmscon/issues/49
                    + " -Wno-error=maybe-uninitialized"
                    # https://github.com/Aetf/kmscon/issues/64
                    + " -Wno-error=implicit-function-declaration";
            });
        })
    ];
    services.kmscon = {
        enable = true;
        hwRender = true;
        fonts = (if target.text.comicCode.enable then [
            {name = target.text.comicCode.name; package = target.text.comicCode.package;}] else [])
        ++ [
            {name = "ComicShannsMono Nerd Font"; package = pkgs.nerdfonts;}
        ];
        extraConfig = ''
            xkb-layout=${target.input.keyLayout}

            font-size=14

            palette=custom
            palette-foreground=${target.style.catppuccin.text.rgb}
            palette-background=${target.style.catppuccin.base.rgb}

            palette-black=${target.style.catppuccin.surface1.rgb}
            palette-red=${target.style.catppuccin.red.rgb}
            palette-green=${target.style.catppuccin.green.rgb}
            palette-yellow=${target.style.catppuccin.peach.rgb}
            palette-blue=${target.style.catppuccin.blue.rgb}
            palette-magenta=${target.style.catppuccin.pink.rgb}
            palette-cyan=${target.style.catppuccin.lavender.rgb}
            palette-light-grey=${target.style.catppuccin.subtext1.rgb}

            palette-dark-grey=${target.style.catppuccin.surface2.rgb}
            palette-light-red=${target.style.catppuccin.maroon.rgb}
            palette-light-green=${target.style.catppuccin.teal.rgb}
            palette-light-yellow=${target.style.catppuccin.yellow.rgb}
            palette-light-blue=${target.style.catppuccin.sky.rgb}
            palette-light-magenta=${target.style.catppuccin.flamingo.rgb}
            palette-light-cyan=${target.style.catppuccin.sapphire.rgb}
            palette-white=${target.style.catppuccin.text.rgb}
        '';
    };

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.${target.userName} = {
        isNormalUser = true;
        description = "Quinn";
        extraGroups = [ "networkmanager" "wheel" ];
        packages = with pkgs; [];
        shell = pkgs.zsh;
    };
    programs.zsh.enable = true;

    # Enable experimental features
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    nixpkgs.config.allowUnfree = true;

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
        _7zz
        git
        radicle-node
        radicle-httpd
        vim
        bash
        lshw
        wget
        curl
        samba
        kmscon
        fastfetch
        (verilator.overrideAttrs rec {
            version = "5.028";
            VERILATOR_SRC_VERSION = "v${version}";
            src = fetchFromGitHub {
                owner = "verilator";
                repo = "verilator";
                rev = "v${version}";
                hash = "sha256-YgK60fAYG5575uiWmbCODqNZMbRfFdOVcJXz5h5TLuE=";
            };
            extraBuildInputs = [pkgs.zlib]; # for .fst file generation
        })
        verible
        verilog
        nil
        haskellPackages.sv2v
        gnumake
        gcc
        inputs.naturaldocs.packages.${pkgs.system}.naturaldocs
    ];

    fonts = {
        fontDir.enable = true;
        packages = with pkgs; [
            nerdfonts
            meslo-lgs-nf
        ] ++ (if target.text.comicCode.enable then [target.text.comicCode.package] else []);
        fontconfig.defaultFonts = {
            monospace = (if target.text.comicCode.enable then [target.text.comicCode.name] else []) ++ [ 
                "ComicShannsMono Nerd Font"
            ];
        };
    };

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = target.stateVer;
}
