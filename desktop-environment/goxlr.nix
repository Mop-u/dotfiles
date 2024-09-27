{inputs, config, pkgs, lib, target, ... }:
{
    services.goxlr-utility.enable = true;
    services.goxlr-utility.autoStart.xdg = true;
}
