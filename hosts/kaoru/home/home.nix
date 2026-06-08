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
    (pkgs.quartusPackages.pro.latestWithDevices [ "cyclone10gx" ])
    pkgs.fiano
    pkgs.uefitoolPackages.old-engine
    pkgs.coreboot-utils
    pkgs.wineWow64Packages.full
  ];

  xdg.autostart.entries = lib.mkIf osConfig.services.asusd.enable [
    "${osConfig.services.asusd.package}/share/applications/rog-control-center.desktop"
  ];

  programs = {
    surfer.enable = true;
    gtkwave.enable = true;
    vscodium = {
      profiles.default = {
        extensions = with pkgs.vsxExtensionsFor config.programs.vscodium.package; [
          mbehr1.vsc-webshark
          #surfer-project.surfer
          lramseyer.vaporview
          redhat.vscode-yaml
          christian-kohler.path-intellisense
          llvm-vs-code-extensions.vscode-clangd
          b-lang-org.language-bh
          hudson-river-trading.vscode-slang
          ms-vscode.hexeditor
          #sankooc.pcapviewer
        ];
        userSettings = {
          "redhat.telemetry.enabled" = false;
          "vsc-webshark.sharkdFullPath" = "${pkgs.wireshark}/bin/sharkd";
          "slang.path" = "${lib.getExe pkgs.slang-server}";
          "workbench.editorAssociations" = {
            #"*.pcap" = "proto.pcapng";
            "*.pcap" = "vsc-webshark.pcap";
          };
        };
      };
    };
  };
}
