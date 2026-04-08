{
    osConfig,
    config,
    pkgs,
    lib,
    ...
}:
{
    home.packages = [
        pkgs.wireshark
        (pkgs.mkQuartus { quartusSource = pkgs.quartusSources.pro.latestWithDevices [ "cyclone10gx" ]; })
        pkgs.fiano
        pkgs.uefitoolPackages.old-engine
        pkgs.coreboot-utils
        pkgs.wineWowPackages.full
    ];

    xdg.autostart.entries = lib.mkIf osConfig.services.asusd.enable [
        "${osConfig.services.asusd.package}/share/applications/rog-control-center.desktop"
    ];

    programs = {
        surfer.enable = true;
        gtkwave.enable = true;
        vscode = {
            profiles.default = {
                extensions = with pkgs.vsxExtensionsFor config.programs.vscode.package; [
                    mbehr1.vsc-webshark
                    surfer-project.surfer
                    redhat.vscode-yaml
                    christian-kohler.path-intellisense
                    mshr-h.veriloghdl
                    llvm-vs-code-extensions.vscode-clangd
                    b-lang-org.language-bh
                    ms-vscode.hexeditor
                    #sankooc.pcapviewer
                ];
                userSettings = {
                    "redhat.telemetry.enabled" = false;
                    "vsc-webshark.sharkdFullPath" = "${pkgs.wireshark}/bin/sharkd";
                    "workbench.editorAssociations" = {
                        #"*.pcap" = "proto.pcapng";
                        "*.pcap" = "vsc-webshark.pcap";

                    };
                };
            };
        };
        ssh = {
            enable = true;
            includes = [ osConfig.sops.secrets."hosts/gio".path ];
            enableDefaultConfig = false;
            matchBlocks."*" = {
                forwardAgent = false;
                addKeysToAgent = "no";
                compression = false;
                serverAliveInterval = 0;
                serverAliveCountMax = 3;
                hashKnownHosts = false;
                userKnownHostsFile = "~/.ssh/known_hosts";
                controlMaster = "no";
                controlPath = "~/.ssh/master-%r@%n:%p";
                controlPersist = "no";
            };
        };
    };
}
