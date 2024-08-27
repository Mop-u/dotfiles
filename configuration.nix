# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, sysConf, ... }:
{

    nix.gc.automatic = true;

    catppuccin = {
        enable = true;
        accent = "mauve";
        flavor = "frappe";
    };

    networking.hostName = sysConf.hostName;#"kaoru"; # Define your hostname.
    # networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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

    # Enable networking
    networking.networkmanager.enable = true;

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
    users.users.${sysConf.userName} = {
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
        git
        vim
        bash
        lshw
        wget
        curl
        fastfetch
        verilator
        verilog
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
            inputs.nonfree-fonts.packages.${pkgs.system}.comic-code
        ];
        fontconfig.defaultFonts = {
            monospace = [ 
                "Comic Code"
                "ComicShannsMono Nerd Font"
            ];
        };
    };

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
    #     enable = true;
    #     enableSSHSupport = true;
    # };

    # List services that you want to enable:

    # Enable the OpenSSH daemon.
    # services.openssh.enable = true;

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = sysConf.stateVer; # Did you read the comment?
}
