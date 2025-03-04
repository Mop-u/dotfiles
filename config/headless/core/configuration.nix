# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, lib, ... }: let
    cfg = config.sidonia;
in {
    boot.initrd.systemd.enable = true;

    networking.hostName = cfg.hostName;

    nix.gc.automatic = true;
    nix.settings.auto-optimise-store = true;
    nix.settings.keep-outputs = true;
    nix.settings.keep-derivations = true;

    sops.defaultSopsFile = ../../../secrets/secrets.yaml;
    sops.defaultSopsFormat = "yaml";
    sops.age.keyFile = "/home/${cfg.userName}/.config/sops/age/keys.txt";

    catppuccin = {
        enable = true;
        accent = cfg.style.catppuccin.accent;
        flavor = cfg.style.catppuccin.flavor;
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

    # Firmware updater
    services.fwupd.enable = true;

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
    services.avahi = {
        enable = true;
        nssmdns4 = true;
        nssmdns6 = true;
        openFirewall = true;
    };

    # Enable printing
    services.printing.enable = true;

    # Enable bluetooth
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;

    # Set your time zone.
    #time.timeZone = lib.mkDefault "Europe/Dublin";
    services.automatic-timezoned.enable = true;
    #services.localtimed.enable = true;

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

    console.keyMap = cfg.input.keyLayout;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.${cfg.userName} = {
        isNormalUser = true;
        description = cfg.lib.capitalize cfg.userName;
        extraGroups = [ "networkmanager" "wheel" ];
        packages = with pkgs; [];
        shell = pkgs.zsh;
    };
    programs.zsh.enable = true;
    programs.direnv.enable = true;

    # Enable experimental features
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    nixpkgs.config.allowUnfree = true;

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
        _7zz
        git
        sops
        vim
        bash
        lshw
        wget
        curl
        tmux
        samba
        ssh-to-age
        fastfetch
        nil
        gnumake
        gcc
        inputs.naturaldocs.packages.${pkgs.system}.naturaldocs
        foot.terminfo
        smartmontools
    ];

    fonts = {
        fontDir.enable = true;
        packages = with pkgs; [
            # 25.05 / unstable
            #nerd-fonts.comic-shanns-mono
            #nerd-fonts.ubuntu
            nerdfonts # 24.11
            liberation_ttf
            meslo-lgs-nf
        ] ++ (lib.optional cfg.text.comicCode.enable  cfg.text.comicCode.package);
        fontconfig.defaultFonts = {
            monospace = (lib.optional cfg.text.comicCode.enable cfg.text.comicCode.name) ++ [ 
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
    system.stateVersion = cfg.stateVer;
}
