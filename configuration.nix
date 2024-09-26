# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, target, ... }:
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
    };
    networking.nftables.enable = true;

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

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.${target.userName} = {
        isNormalUser = true;
        description = "Quinn";
        extraGroups = [ "networkmanager" "wheel" ];
        packages = with pkgs; [];
    };

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
        fastfetch
        verilator
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
