{inputs, config, pkgs, lib, target, ... }: let
    stextTop = "/home/${target.userName}/.config/sublime-text";
    stextCfg = "${stextTop}/Packages";
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
                "${target.window.float.onCursor}, class:(ssh-askpass-sublime)"
            ];
        };
        home.file = {
            stextPackageControlPackage = {
                enable = true;
                executable = false;
                target = "${stextCfg}/Package Control";
                source = inputs.stextPackageControl;
            };
            stextPatchedSublimeLinterContribVerilator = {
                enable = true;
                executable = false;
                target = "${stextCfg}/SublimeLinter-contrib-verilator";
                source = inputs.patchedSublimeLinterContribVerilator;
            };
            stextPreferences = {
                enable = true;
                executable = false;
                target = "${stextCfg}/User/Preferences.sublime-settings";
                text = ''
                {
                    "ignored_packages":
                    [
                        "Vintage",
                    ],
                    "font_size": 12,
                    "translate_tabs_to_spaces": true,
                    "index_files": false,
                    "hardware_acceleration": "${if target.legacyGpu then "none" else "opengl"}",
                    "theme": "Adaptive.sublime-theme",
                    "color_scheme": "Catppuccin ${target.helper.capitalize target.style.catppuccin.flavor}.sublime-color-scheme",
                    "update_check": false,
                    "sublime_merge_path": ${if target.helper.isInstalled pkgs.sublime-merge then "\"${pkgs.sublime-merge}/bin/sublime_merge\"" else "null"},
                }
                '';
            };
            stextPackageControlConfig = {
                enable = true;
                executable = false;
                target = "${stextCfg}/User/Package Control.sublime-settings";
                text = ''
                {
                    "bootstrapped": true,
                    "in_process_packages":
                    [
                    ],
                    "installed_packages":
                    [
                        "Catppuccin color schemes",
                        "LSP",
                        "Nix",
                        "SublimeLinter",
                        "SystemVerilog",
                    ]
                }
                '';
            };
            stextSublimeLinter = {
                enable = true;
                executable = false;
                target = "${stextCfg}/User/SublimeLinter.sublime-settings";
                text = ''
                {
                    "no_column_highlights_line": true,
                    "debug": false,
                    "linters":
                    {
                        "verilator": {
                            "disable": ${if target.helper.isInstalled pkgs.verilator then "false" else "true"},
                            "lint_mode": "load_save",
                            "styles" : [
                                {
                                    "types": ["warning"],
                                    "mark_style": "squiggly_underline",
                                    "icon": "Packages/SublimeLinter/gutter-themes/Default/cog.png"
                                },
                                {
                                    "types": ["error"],
                                    "mark_style": "fill",
                                    "icon": "Packages/SublimeLinter/gutter-themes/Default/cog.png"
                                }
                            ],
                            "args": [
                                "--error-limit",
                                "500",
                                "--default-language",
                                "1800-2005",
                                "-Wall",
                            ],

                            "verilator_version"  : 5,
                            "use_multiple_source": true,
                            "search_project_path": true,

                            // windows subsystem for linux (wsl verilator_bin)
                            "use_wsl": false,

                            // additional option to filter file type
                            "extension": [
                                ".v", ".sv", ".svh", ".vh"
                            ],
                        }
                    }
                }
                '';
            };
            stextLSP = {
                enable = true;
                executable = false;
                target = "${stextCfg}/User/LSP.sublime-settings";
                text = ''
                {
                    "clients": {
                        "verilbe": {
                            "enabled": ${if target.helper.isInstalled pkgs.verible then "true" else "false"},
                            "command": [
                                "verible-verilog-ls",
                                "--rules_config_search"
                            ],
                            "selector": "source.systemverilog"
                        },
                        "nil": {
                            "enabled": ${if target.helper.isInstalled pkgs.nil then "true" else "false"},
                            "command": [
                                "nil"
                            ],
                            "selector": "source.nix"
                        }
                    }
                }
                '';
            };
        };
    };
}
