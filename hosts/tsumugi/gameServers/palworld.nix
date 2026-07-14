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
    openFirewall = true;
    appId = 2394010;
    executable = "PalServer.sh";
    args = [
      "-useperfthreads"
      "-NoAsyncLoadingThread"
      "-UseMultithreadForDS"
    ];
    udpPorts = [ 8211 ];
  };
}
