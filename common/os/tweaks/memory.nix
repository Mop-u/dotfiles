# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.sidonia;
in
{
  options.sidonia.tweaks.memory.enable = lib.mkEnableOption "Enable memory tweaks";
  config = lib.mkIf cfg.tweaks.memory.enable {

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
  };
}
