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
  imports = [
    ./os
  ];
  home-manager.users.${cfg.userName}.imports = [
    ./hm
  ];
}
