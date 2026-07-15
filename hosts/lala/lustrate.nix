{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.boot.initrd.systemd;
in

{
  options = {
    boot.initrd.systemd.lustrate.enable = lib.mkEnableOption "lustration" // {
      description = ''
        Whether to enable lustration in the systemd initrd. This is used for
        installation from another distribution. Please see [the manual] for
        more details.

        This option only has an effect if systemd initrd is enabled with the
        `boot.initrd.systemd.enable` option. If systemd initrd is disabled,
        lustration is always available.

        Warning: Lustration may interact unexpectedly with complex filesystem
        setups. Use with caution.

        [the manual]: https://nixos.org/manual/nixos/stable#sec-installing-from-other-distro
      '';
    };
  };

  config = lib.mkIf (cfg.enable && cfg.lustrate.enable) {
    boot.initrd.systemd.services.lustrate = {
      description = "Lustration of the root filesystem";

      unitConfig = {
        ConditionPathExists = [ "/sysroot/etc/NIXOS_LUSTRATE" ];

        # We need to lustrate after /sysroot is mounted, but before anything
        # else is mounted on top.
        Requires = [ "sysroot.mount" ];
        After = [
          "sysroot.mount"
          "systemd-repart.service"
        ];
        Before = [
          "initrd-root-fs.target"
          "systemd-volatile-root.service"

          # NixOS adds or may add these mounts that are not ordered after
          # initrd-root-fs.target. This may or may not be a bug on NixOS's part.
          "sysroot-run.mount"
          "sysroot-etc.mount"
        ];
      };
      requiredBy = [ "initrd.target" ];

      serviceConfig = {
        Type = "oneshot";
        StandardOutput = "journal+console";
        StandardError = "journal+console";
      };

      path = [ pkgs.coreutils ];

      script = ''
        # This script is a copy of a substantial portion of code from Nixpkgs,
        # modified for use as a Systemd unit. The original license, namely MIT,
        # applies to this script.
        #
        # SPDX-SnippetBegin
        # SPDX-License-Identifier: MIT
        # SPDX-SnippetComment: Based on https://github.com/NixOS/nixpkgs/blob/fe327712db0e01d9a6ee0a25028c39bb83aa28f9/nixos/modules/system/boot/stage-1-init.sh#L444-L481
        # SPDX-SnippetCopyrightText: Copyright (c) 2003-2026 Eelco Dolstra and the Nixpkgs/NixOS contributors
        #
        # Permission is hereby granted, free of charge, to any person obtaining
        # a copy of this software and associated documentation files (the
        # "Software"), to deal in the Software without restriction, including
        # without limitation the rights to use, copy, modify, merge, publish,
        # distribute, sublicense, and/or sell copies of the Software, and to
        # permit persons to whom the Software is furnished to do so, subject to
        # the following conditions:
        #
        # The above copyright notice and this permission notice shall be
        # included in all copies or substantial portions of the Software.
        #
        # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
        # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
        # MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
        # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
        # LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
        # OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
        # WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

        lustrateRoot () {
          local root="$1"

          echo
          echo -e "\e[1;33m<<< ${config.system.nixos.distroName} is now lustrating the root filesystem (cruft goes to /old-root) >>>\e[0m"
          echo

          mkdir -m 0755 -p "$root/old-root.tmp"

          echo
          echo "Moving impurities out of the way:"
          for d in "$root"/*
          do
              [ "$d" == "$root/nix"          ] && continue
              [ "$d" == "$root/boot"         ] && continue # Don't render the system unbootable
              [ "$d" == "$root/old-root.tmp" ] && continue

              mv -v "$d" "$root/old-root.tmp"
          done

          # Use .tmp to make sure subsequent invocations don't clash
          mv -v "$root/old-root.tmp" "$root/old-root"

          mkdir -m 0755 -p "$root/etc"
          touch "$root/etc/NIXOS"

          exec 4< "$root/old-root/etc/NIXOS_LUSTRATE"

          echo
          echo "Restoring selected impurities:"
          while read -u 4 keeper; do
              dirname="$(dirname "$keeper")"
              mkdir -m 0755 -p "$root/$dirname"
              cp -av "$root/old-root/$keeper" "$root/$keeper"
          done

          exec 4>&-
        }

        set -euo pipefail

        # Should be checked by systemd, but I find this convenient for testing
        [ -f "/sysroot/etc/NIXOS_LUSTRATE" ] || exit 0
        lustrateRoot /sysroot

        # SPDX-SnippetEnd
      '';
    };
  };
}
