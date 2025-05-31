# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
    config,
    pkgs,
    inputs,
    lib,
    ...
}:
let
    cfg = config.sidonia;
in
{
    boot.initrd.systemd.enable = true;

    networking.hostName = cfg.hostName;

    # https://github.com/NixOS/nixpkgs/issues/389928
    system.switch.enableNg = false;

    nix.gc.automatic = true;
    nix.settings.auto-optimise-store = true;
    nix.settings.trusted-users = [ cfg.userName ];

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

    # https://cmm.github.io/soapbox/the-year-of-linux-on-the-desktop.html
    zramSwap.enable = true;
    # use values deemed by folk wisdom to be optimal with zstd zram swap
    boot.kernel.sysctl = {
        "vm.swappiness" = 180;
        "vm.page-cluster" = 0;
        "vm.watermark_scale_factor" = 125;
        "vm.watermark_boost_factor" = 0;
    };

    # use the handy system76-scheduler service (it is not in fact specific
    # to System76 hardware, despite the name)
    services.system76-scheduler = {
        enable = true;
        useStockConfig = false; # our needs are modest
        settings = {
            # CFS profiles are switched between "default" and "responsive"
            # according to power source ("default" on battery, "responsive" on
            # wall power).  defaults are fine, except maybe this:
            cfsProfiles.default.preempt = "voluntary";
            # "voluntary" supposedly conserves battery but may also allow some
            # audio skips, so consider changing to "full"
            processScheduler = {
                # Pipewire client priority boosting is not needed when all else is
                # configured properly, not to mention all the implied
                # second-guessing-the-kernel and priority inversions, so:
                pipewireBoost.enable = false;
                # I believe this exists solely for the placebo effect, so disable:
                foregroundBoost.enable = false;
            };
        };
        assignments = {
            # confine builders / compilers / LSP servers etc. to the "batch"
            # scheduling class automagically.  add matchers to taste!
            batch = {
                class = "batch";
                matchers = [
                    "bazel"
                    "clangd"
                    "rust-analyzer"
                ];
            };
        };
        # do not disturb adults:
        exceptions = [
            "include descends=\"schedtool\""
            "include descends=\"nice\""
            "include descends=\"chrt\""
            "include descends=\"taskset\""
            "include descends=\"ionice\""

            "schedtool"
            "nice"
            "chrt"
            "ionice"

            "dbus"
            "dbus-broker"
            "rtkit-daemon"
            "taskset"
            "systemd"
        ];
    };

    systemd =
        let
            accounting = ''
                DefaultCPUAccounting=yes
                DefaultMemoryAccounting=yes
                DefaultIOAccounting=yes
            '';
        in
        {
            # tell Systemd to measure things (probably the default these days?
            # doesn't hurt, anyway):
            extraConfig = accounting;
            user.extraConfig = accounting;
            services."user@".serviceConfig.Delegate = true;

            # enable MGLRU.  change the min_ttl_ms value to taste
            services."config-mglru" = {
                enable = true;
                after = [ "basic.target" ];
                wantedBy = [ "sysinit.target" ];
                script = with pkgs; ''
                    ${coreutils}/bin/echo Y > /sys/kernel/mm/lru_gen/enabled
                    ${coreutils}/bin/echo 1000 > /sys/kernel/mm/lru_gen/min_ttl_ms
                '';
            };

            # configure systemd-oomd properly
            oomd = {
                enable = true;
                # disable the provided knobs -- they are too coarse, and also swap
                # monitoring seems like a bad idea, with btrfs anyway
                enableRootSlice = false;
                enableSystemSlice = false;
                enableUserSlices = false;
                # change if 4s is too fast
                extraConfig.DefaultMemoryPressureDurationSec = "4s";
            };

            # kill off stuff if absolutely needed, limit to things killing which
            # is unlikely to gimp system/desktop irreversibly, go only by PSI.
            # tweak limits to taste, but be careful not to make them too high or
            # you'll get the kernel OOM killer (on my machine 35% is too high, for
            # example)
            user.slices."app".sliceConfig = {
                ManagedOOMMemoryPressure = "kill";
                ManagedOOMMemoryPressureLimit = "16%";
            };
            slices."background".sliceConfig = {
                ManagedOOMMemoryPressure = "kill";
                ManagedOOMMemoryPressureLimit = "8%";
            };
            user.slices."background".sliceConfig = {
                ManagedOOMMemoryPressure = "kill";
                ManagedOOMMemoryPressureLimit = "8%";
            };
        };

    #######################################################################

    # Firmware updater
    services.fwupd.enable = true;

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
    networking.firewall.allowedUDPPorts = [ 5353 ];
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
    time.timeZone = lib.mkDefault "Europe/Dublin";
    #services.automatic-timezoned.enable = true;
    services.localtimed.enable = cfg.geolocation.enable;
    services.geoclue2 = {
        enable = cfg.geolocation.enable;
        geoProviderUrl = "https://beacondb.net/v1/geolocate";
    };

    # Select internationalisation properties.
    i18n.defaultLocale = "en_GB.UTF-8";

    i18n.extraLocaleSettings = {
        LC_ADDRESS = "en_IE.UTF-8";
        LC_IDENTIFICATION = "en_IE.UTF-8";
        LC_MEASUREMENT = "en_IE.UTF-8";
        LC_MONETARY = "en_IE.UTF-8";
        LC_NAME = "en_IE.UTF-8";
        LC_NUMERIC = "en_IE.UTF-8";
        LC_PAPER = "en_IE.UTF-8";
        LC_TELEPHONE = "en_IE.UTF-8";
        LC_TIME = "en_IE.UTF-8";
    };

    console.keyMap = cfg.input.keyLayout;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.${cfg.userName} = {
        isNormalUser = true;
        description = cfg.lib.capitalize cfg.userName;
        extraGroups = [
            "networkmanager"
            "wheel"
        ];
        packages = with pkgs; [ ];
        shell = pkgs.zsh;
    };
    programs.zsh.enable = true;
    programs.direnv.enable = true;

    # Enable experimental features
    nix.settings.experimental-features = [
        "nix-command"
        "flakes"
    ];

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
        foot.terminfo
        smartmontools
        usbutils
        inputs.nixfmt-git.packages.${pkgs.system}.default
    ];

    fonts = {
        fontDir.enable = true;
        packages =
            with pkgs;
            [
                # 25.05 / unstable
                nerd-fonts.comic-shanns-mono
                nerd-fonts.ubuntu
                liberation_ttf
                meslo-lgs-nf
                dejavu_fonts
            ]
            ++ (lib.optional cfg.text.comicCode.enable cfg.text.comicCode.package);
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
