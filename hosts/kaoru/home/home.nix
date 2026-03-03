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
