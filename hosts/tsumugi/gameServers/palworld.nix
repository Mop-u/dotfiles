{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
{
  services.steamcmd-servers.palworld = {
    enable = true;
    appId = 2394010;
    executable = "PalServer.sh";
    args = [
      "-useperfthreads"
      "-NoAsyncLoadingThread"
      "-UseMultithreadForDS"
    ];
    autoUpdate = true;
    openFirewall = true;
    udpPorts = [ 8211 ];
  };
  networking.firewall.allowedUDPPorts = [ 8211 ];
}
