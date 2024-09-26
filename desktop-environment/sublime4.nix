{inputs, config, pkgs, lib, target, ... }: let
    stextTop = "/home/${target.userName}/.config/sublime-text";
    stextPkg = "${stextTop}/Packages";
    stextCfg = "${stextPkg}/User";
in {

    nixpkgs.config.permittedInsecurePackages = [
        "openssl-1.1.1w"  # for sublime4 & sublime-merge :(
    ]; 

    home-manager.users.${target.userName} = {
        home.packages = with pkgs; [
            sublime4
            sublime-merge
        ];
        wayland.windowManager.hyprland.settings = {
            windowrulev2 = [
                "float,                          class:(sublime_text), title:(Select Folder)"
                "size ${target.window.float.wh}, class:(sublime_text), title:(Select Folder)"

                "float,                           class:(ssh-askpass-sublime)"
            ];
        };
        home.file = {
            # Packages
            stextPackageControl = {
                enable = true;
                executable = false;
                target = "${stextPkg}/Package Control";
                source = inputs.stextPackageControl;
            };
            stextSublimeLinterContribVerilator = {
                enable = true;
                executable = false;
                target = "${stextPkg}/SublimeLinter-contrib-verilator";
                source = inputs.stextSublimeLinterContribVerilator;
            };
            stextCatppuccin = {
                enable = true;
                executable = false;
                target = "${stextPkg}/Catppuccin color schemes";
                source = inputs.stextCatppuccin;
            };
            stextLSP = {
                enable = true;
                executable = false;
                target = "${stextPkg}/LSP";
                source = inputs.stextLSP;
            };
            stextNix = {
                enable = true;
                executable = false;
                target = "${stextPkg}/Nix";
                source = inputs.stextNix;
            };
            stextSublimeLinter = {
                enable = true;
                executable = false;
                target = "${stextPkg}/SublimeLinter";
                source = inputs.stextSublimeLinter;
            };
            stextSystemVerilog = {
                enable = true;
                executable = false;
                target = "${stextPkg}/SystemVerilog";
                source = inputs.stextSystemVerilog;
            };
            # Config
            stextCfg = {
                enable = true;
                executable = false;
                target = "${stextCfg}/Preferences.sublime-settings";
                text = builtins.toJSON {
                    ignored_packages = ["Vintage"];
                    font_size = if target.text.smallTermFont then 11 else 12;
                    translate_tabs_to_spaces = true;
                    index_files = true;
                    hardware_acceleration = if target.legacyGpu then "none" else "opengl";
                    theme = "Adaptive.sublime-theme";
                    color_scheme = "Catppuccin ${target.helper.capitalize target.style.catppuccin.flavor}.sublime-color-scheme";
                    update_check = false;
                    sublime_merge_path = if target.helper.isInstalled pkgs.sublime-merge then "\"${pkgs.sublime-merge}/bin/sublime_merge\"" else null;
                };
            };
            stextSublimeLinterCfg = {
                enable = true;
                executable = false;
                target = "${stextCfg}/SublimeLinter.sublime-settings";
                text = builtins.toJSON {
                    no_column_highlights_line = true;
                    debug = false;
                    linters = {
                        verilator = {
                            disable = if target.helper.isInstalled pkgs.verilator then false else true;
                            lint_mode = "load_save";
                            styles = [
                                {
                                    types = ["warning"];
                                    mark_style = "squiggly_underline";
                                    icon = "Packages/SublimeLinter/gutter-themes/Default/cog.png";
                                }
                                {
                                    types = ["error"];
                                    mark_style = "fill";
                                    icon = "Packages/SublimeLinter/gutter-themes/Default/cog.png";
                                }
                            ];
                            args = [
                                "--error-limit"
                                "500"
                                "--default-language"
                                "1800-2005"
                                "-Wall"
                            ];

                            verilator_version = 5;
                            use_multiple_source = true;
                            search_project_path = true;

                            use_wsl = false;

                            extension = [
                                ".v" ".sv" ".svh" ".vh"
                            ];
                        };
                    };
                };
            };
            stextLSPCfg = {
                enable = true;
                executable = false;
                target = "${stextCfg}/LSP.sublime-settings";
                text = builtins.toJSON {
                    clients = {
                        verilbe = {
                            enabled = if target.helper.isInstalled pkgs.verible then true else false;
                            command = [
                                "verible-verilog-ls"
                                "--rules_config_search"
                            ];
                            selector = "source.systemverilog";
                        };
                        nil = {
                            enabled = if target.helper.isInstalled pkgs.nil then true else false;
                            command = ["nil"];
                            selector = "source.nix";
                        };
                    };
                };
            };
        };
    };
}
