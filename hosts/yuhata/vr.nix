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
    hardware.steam-hardware.enable = true;
    programs.steam = {
        package = pkgs.steam.override {
            extraProfile = ''
                # Fixes timezones on VRChat
                unset TZ
                # Allows Monado to be used
                export PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES=1
            '';
        };
        extraCompatPackages = [
            pkgs.proton-ge-rtsp-bin
        ];
    };
    services.monado = {
        enable = true;
        defaultRuntime = true;
        highPriority = true;
    };
    systemd.user.services.monado.environment = {
        STEAMVR_LH_ENABLE = "1";
        XRT_COMPOSITOR_COMPUTE = "1";
        WMR_HANDTRACKING = "0";
        #IPC_EXIT_ON_DISCONNECT = "1";
    };
    home-manager.users.${cfg.userName} = {
        home.packages = [
            pkgs.xrizer
            pkgs.wlx-overlay-s
        ];
        xdg.configFile = {
            "openxr/1/active_runtime.json".source = "${pkgs.monado}/share/openxr/1/openxr_monado.json";
            "openvr/openvrpaths.vrpath".text =
                let
                    steamDir = "${config.home-manager.users.${cfg.userName}.xdg.dataHome}/Steam";
                in
                builtins.toJSON {
                    version = 1;
                    jsonid = "vrpathreg";
                    external_drivers = null;
                    config = [ "${steamDir}/config" ];
                    log = [ "${steamDir}/logs" ];
                    runtime = [ "${pkgs.xrizer}/lib/xrizer" ];
                };
        };
    };

}
