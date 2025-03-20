{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:
let
    cfg = config.sidonia;
    theme = cfg.style.catppuccin;
    stextTop = "/home/${cfg.userName}/.config/sublime-text";
    stextPkg = stextTop + "/Packages";
    stextCfg = stextTop + "/Packages/User";
    smergeTop = "/home/${cfg.userName}/.config/sublime-merge";
    smergePkg = smergeTop + "/Packages";
    smergeCfg = smergeTop + "/Packages/User";
    catppuccinBaseName = "Catppuccin " + cfg.lib.capitalize theme.flavor;
    catppuccinColorScheme = catppuccinBaseName + ".sublime-color-scheme";
in
{
    options.sidonia.programs = with lib; {
        sublime-text = {
            enable = mkOption {
                type = types.bool;
                default = cfg.graphics.enable;
            };
        };
        sublime-merge = {
            enable = mkOption {
                type = types.bool;
                default = cfg.graphics.enable;
            };
        };
    };
    config = {

        nixpkgs.config.permittedInsecurePackages = lib.optional (
            cfg.programs.sublime-text.enable || cfg.programs.sublime-merge.enable
        ) "openssl-1.1.1w";

        home-manager.users.${cfg.userName} = {
            home.packages =
                with pkgs;
                (lib.optionals cfg.programs.sublime-text.enable [ sublime4 ])
                ++ (lib.optional cfg.programs.sublime-merge.enable sublime-merge);

            wayland.windowManager.hyprland.settings = lib.mkIf cfg.programs.sublime-merge.enable {
                windowrulev2 = [
                    "float, class:(ssh-askpass-sublime)"
                ];
            };

            home.file = lib.mkMerge [
                (lib.mkIf (cfg.programs.sublime-text.enable || cfg.programs.sublime-merge.enable) {
                    stextCatppuccin = {
                        enable = true;
                        target = stextPkg + "/Catppuccin color schemes";
                        source = inputs.stextCatppuccin;
                    };
                })
                (lib.mkIf cfg.programs.sublime-text.enable {
                    # Packages
                    stextPackageControl = {
                        enable = true;
                        target = stextPkg + "/Package Control";
                        source = inputs.stextPackageControl;
                    };
                    stextLSP = {
                        enable = true;
                        target = stextPkg + "/LSP";
                        source = inputs.stextLSP;
                    };
                    stextNix = {
                        enable = true;
                        target = stextPkg + "/Nix";
                        source = inputs.stextNix;
                    };
                    stextSystemVerilog = {
                        enable = true;
                        target = stextPkg + "/SystemVerilog";
                        source = inputs.stextSystemVerilog;
                    };
                    stextHooks = {
                        enable = true;
                        target = stextPkg + "/hooks";
                        source = inputs.stextHooks;
                    };

                    #Config
                    stextCfg = {
                        enable = true;
                        target = stextCfg + "/Preferences.sublime-settings";
                        text = builtins.toJSON {
                            ignored_packages = [ "Vintage" ];
                            font_size = if cfg.text.smallTermFont then 10 else 11;
                            translate_tabs_to_spaces = true;
                            index_files = true;
                            hardware_acceleration = if cfg.graphics.legacyGpu then "none" else "opengl";
                            theme = "Adaptive.sublime-theme";
                            color_scheme = catppuccinColorScheme;
                            update_check = false;
                            sublime_merge_path =
                                if cfg.programs.sublime-merge.enable then "${pkgs.sublime-merge}/bin/sublime_merge" else null;
                        };
                    };
                    stextSystemVerilogCfg = {
                        enable = true;
                        target = stextCfg + "/SystemVerilog.sublime-settings";
                        text = builtins.toJSON {
                            "sv.disable_autocomplete" = true;
                            "sv.tooltip" = true;
                        };
                    };
                    stextLSPCfg = {
                        enable = true;
                        target = stextCfg + "/LSP.sublime-settings";
                        text = builtins.toJSON {
                            clients = {
                                verible = {
                                    enabled = cfg.lib.isInstalled pkgs.verible;
                                    command = [
                                        "verible-verilog-ls"
                                        "--rules_config_search"
                                    ];
                                    selector = "source.systemverilog";
                                };
                                nil = {
                                    enabled = cfg.lib.isInstalled pkgs.nil;
                                    command = [ "nil" ];
                                    selector = "source.nix";
                                    # https://github.com/oxalica/nil/blob/main/docs/configuration.md
                                    settings = {
                                        nil.nix.flake = {
                                            autoArchive = true;
                                            autoEvalInputs = true;
                                        };
                                    };
                                };
                                svls = {
                                    enabled = cfg.lib.isInstalled pkgs.svls;
                                    command = [ "svls" ];
                                    selector = "source.systemverilog";
                                };
                            };
                        };
                    };
                })
                (lib.mkIf cfg.programs.sublime-merge.enable {
                    smergeCfg = {
                        enable = true;
                        target = smergeCfg + "/Preferences.sublime-settings";
                        text = builtins.toJSON {
                            theme = "${catppuccinBaseName}.sublime-theme";
                            translate_tabs_to_spaces = true;
                            side_bar_layout = "tabs";
                            font_size = if cfg.text.smallTermFont then 10 else 11;
                            hardware_acceleration = if cfg.graphics.legacyGpu then "none" else "opengl";
                            update_check = false;
                            editor_path =
                                if cfg.lib.isInstalled pkgs.sublime4 then "${pkgs.sublime4}/bin/sublime_text" else null;
                        };
                    };
                    smergeCommitMessageCfg = {
                        enable = true;
                        target = smergeCfg + "/Commit Message - ${catppuccinBaseName}.sublime-settings";
                        text = builtins.toJSON {
                            color_scheme = catppuccinColorScheme;
                        };
                    };
                    smergeDiffCfg = {
                        enable = true;
                        target = smergeCfg + "/Diff - ${catppuccinBaseName}.sublime-settings";
                        text = builtins.toJSON {
                            color_scheme = catppuccinColorScheme;
                        };
                    };
                    smergeFileModeCfg = {
                        enable = true;
                        target = smergeCfg + "/File Mode - ${catppuccinBaseName}.sublime-settings";
                        text = builtins.toJSON {
                            color_scheme = catppuccinColorScheme;
                        };
                    };

                    # based on https://github.com/bitsper2nd/merge-mariana-theme
                    smergeThemeOverride = {
                        enable = true;
                        target = smergeCfg + "/${catppuccinBaseName}.sublime-theme";
                        text =
                            let
                                palette = lib.mapAttrs (n: v: "#${v.hex}") theme.color;
                            in
                            with palette;
                            builtins.toJSON {
                                extends = "Merge.sublime-theme";
                                variables = {
                                    inherit
                                        pink
                                        red
                                        maroon
                                        yellow
                                        green
                                        teal
                                        blue
                                        lavender
                                        text
                                        ;

                                    white = "hsl(0, 0%, 95%)";
                                    text-heading = subtext1;
                                    text-light = subtext0; # "color(${text} a(- 40%))"
                                    darken = "hsl(0, 0%, 13%)";

                                    orange = peach;
                                    cyan = sapphire;
                                    purple = mauve;

                                    # Alias for pink
                                    magenta = pink;
                                    dark_red = "color(${red} s(25%) l(35%))";
                                    dark_blue = "color(${blue}) s(25%) l(35%))";

                                    # Labels
                                    label_color = "var(text-heading)";
                                    help_label_color = "var(text-light)"; # "color(var(text-heading) a(0.6))";

                                    # Header
                                    title_bar_style = "dark";
                                    header_bg = base;
                                    header_fg = "var(text-heading)";
                                    header_button_bg = surface1; # "color(${base} l(25%))";
                                    icon_button_fg = text;

                                    info_shadow = "color(black a(0.2))";

                                    diverged_bg = "color(var(orange) l(- 5%) s(- 20%))";
                                    diverged_button_bg = "var(button_bg)";
                                    diverged_button_fg = base;

                                    # Scroll shadow
                                    scroll_shadow = "color(black a(0.3))";

                                    # Focus highlight
                                    focus_highlight_color = text;

                                    # Welcome overlay
                                    welcome_bg = "color(${base} l(- 5%))";
                                    recent_repositories_row_bg-hover = "color(${base} l(+ 5%))";

                                    # Preferences Page
                                    preferences_overlay_bg = "color(${base} l(+ 5%))";
                                    preferences_section_table_bg = base;

                                    # Side bar
                                    location_bar_fg = text;
                                    location_bar_heading_fg = "var(text-heading)";
                                    location_bar_heading_shadow = "black";
                                    location_bar_row_bg-hover = "color(${base} l(+ 30%) a(0.25))";
                                    disclosure_fg = text;

                                    # Commit list
                                    commit_list_bg = mantle;
                                    commit_row_bg-hover = base;
                                    commit_summary_fg-primary = "var(text-heading)";
                                    commit_summary_fg-secondary = "var(text-light)";
                                    commit_color_count = 8;

                                    commit_edge_0 = blue;
                                    commit_edge_1 = mauve;
                                    commit_edge_2 = pink;
                                    commit_edge_3 = peach;
                                    commit_edge_4 = yellow;
                                    commit_edge_5 = green;
                                    commit_edge_6 = red;
                                    commit_edge_7 = sapphire;

                                    # Annotations
                                    commit_annotation_fg = base;
                                    commit_annotation_fg_inverted = base;
                                    commit_annotation_bg = sapphire;

                                    commit_annotation_fg_0_border = "var(commit_edge_0)";
                                    commit_annotation_fg_1_border = "var(commit_edge_1)";
                                    commit_annotation_fg_2_border = "var(commit_edge_2)";
                                    commit_annotation_fg_3_border = "var(commit_edge_3)";
                                    commit_annotation_fg_4_border = "var(commit_edge_4)";
                                    commit_annotation_fg_5_border = "var(commit_edge_5)";
                                    commit_annotation_fg_6_border = "var(commit_edge_6)";
                                    commit_annotation_fg_7_border = "var(commit_edge_7)";

                                    commit_annotation_bg_inverted_0 = "color(var(commit_edge_0))";
                                    commit_annotation_bg_inverted_1 = "color(var(commit_edge_1))";
                                    commit_annotation_bg_inverted_2 = "color(var(commit_edge_2))";
                                    commit_annotation_bg_inverted_3 = "color(var(commit_edge_3))";
                                    commit_annotation_bg_inverted_4 = "color(var(commit_edge_4))";
                                    commit_annotation_bg_inverted_5 = "color(var(commit_edge_5))";
                                    commit_annotation_bg_inverted_6 = "color(var(commit_edge_6))";
                                    commit_annotation_bg_inverted_7 = "color(var(commit_edge_7))";

                                    # Location Bar
                                    side_bar_container_bg = base;

                                    # Table of Contents
                                    table_of_contents_bg = "color(${base} l(+ 3%))";
                                    table_of_contents_fg = text;
                                    table_of_contents_heading_fg = "var(text-heading)";
                                    table_of_contents_row_bg = "color(${base} l(+ 30%))";

                                    # Detail panel
                                    detail_panel_bg = base;
                                    field_name_fg = text;
                                    author_fg = overlay2; # "color(var(white) a(0.4))";
                                    terminator_fg = text;

                                    remote_ann_fg = "color(${base} a(0.7))";
                                    remote_ann_bg = green;

                                    stash_ann_fg = text;
                                    stash_ann_bg = surface1; # "color(var(white) a(20%))"
                                    stash_ann_border = overlay2; # "color(var(white) a(50%))";

                                    tag_ann_fg = base;
                                    tag_ann_bg = yellow;
                                    tag_ann_opacity = 0.4;

                                    file_ann_fg = base;
                                    file_ann_bg = blue;

                                    submodule_ann_fg = text;
                                    submodule_ann_bg = surface1; # "color(var(white) a(20%))"
                                    submodule_light_ann_fg = text;
                                    submodule_light_ann_bg = surface1; # "color(var(white) a(20%))"

                                    inserted_ann_bg = "color(${green} a(0.50))";
                                    deleted_ann_bg = "color(${red} a(0.50))";

                                    # Diff headers
                                    file_diff_shadow = "color(black a(0.5))";
                                    file_icon_bg = "color(${text} a(0.2))";

                                    hunk_button_fg = text;
                                    hunk_button_shadow = "color(black a(0.5))";

                                    file_header_bg = surface0; # "color(${base} l(+ 5%))";
                                    file_header_bg-hover = surface1; # "color(${base} l(+ 10%))";

                                    hunk_header_bg = base; # "color(${base} l(+ 12%))";

                                    deleted_icon_fg = text;
                                    deleted_header_bg = red;
                                    deleted_header_bg-hover = "color(${red} l(+ 5%))";

                                    unmerged_icon_fg = text;
                                    unmerged_header_bg = blue;
                                    unmerged_header_bg-hover = "color(${blue}) l(+ 3%))";

                                    recent_icon_fg = yellow;
                                    recent_icon_bg = "transparent";
                                    untracked_header_bg = surface0; # "color(${base} s(- 5%) l(+ 15%))";
                                    untracked_header_bg-hover = surface1; # "color(var(untracked_header_bg) l(+ 5%))";

                                    full_context_icon_bg = text;

                                    staged_icon_fg = text;

                                    renamed_file_inserted = "color(${green} s(30%) l(60%))";
                                    renamed_file_deleted = "color(${red} s(50%) l(65%))";

                                    # Blame
                                    blame_popup_bg = surface0;

                                    # Buttons
                                    button_bg = overlay0; # "color(var(white) a(20%))"
                                    button_fg = "var(label_color)";
                                    button_shadow = "color(black a(0.5))";

                                    highlighted_button_light_bg = "color(${green} a(75%))";
                                    highlighted_button_light_fg = text;
                                    highlighted_button_dark_bg = "color(${green} a(75%))";
                                    highlighted_button_dark_fg = text;
                                    highlighted_button_shadow = "color(black a(0.5) l(+ 10%))";

                                    toggle_button_bg = overlay0; # "color(var(white) a(20%))" # This matches the header hover buttons
                                    toggle_button_fg = text;
                                    toggle_button_fg_selected = "var(text-heading)";

                                    # Tabs
                                    tab_bar_bg = base;
                                    tab_separator_bg = base;

                                    # Radio buttons
                                    radio_back = base;
                                    radio_selected = accent;
                                    radio_border-selected = accent;

                                    # Checkbox buttons
                                    checkbox_back = base;
                                    checkbox_selected = accent;
                                    checkbox_border-selected = accent;

                                    # Dialogs
                                    dialog_bg = base;
                                    dialog_button_bg = overlay0; # "color(var(white) a(20%))"

                                    # Progress bar
                                    progress_bg = "var(header_button_bg)";
                                    progress_fg = "color(${accent}))";

                                    # Quick panel
                                    quick_panel_bg = base;
                                    quick_panel_row_bg = surface0;
                                    quick_panel_fg = text;
                                    quick_panel_fg-match = accent;
                                    quick_panel_fg-selected = text;
                                    quick_panel_fg-selected-match = accent;
                                    quick_panel_path_fg = "var(text-light)";
                                    quick_panel_path_fg-match = accent;
                                    quick_panel_path_fg-selected = "var(text-light)";
                                    quick_panel_path_fg-selected-match = accent;

                                    switch_repo_bg = base;

                                    # Image Diffs
                                    image_diff_checkerboard_alt_bg = surface0;
                                    image_metadata_label_bg = surface1;

                                    # Hints
                                    failed_label_fg = base;

                                    # Loading
                                    loading_ball_1 = pink;
                                    loading_ball_2 = green;

                                    # Command Palette
                                    preview_fg = "white";

                                    # Merge Helper
                                    merge_helper_highlight_bg = surface1;
                                    console_border = "color(${base} l(+ 10%))";

                                    # Tabs
                                    repository_tab_bar_bg = base;
                                    repository_tab_bar_border_bg = base;

                                    file_badge_created_fg = green;
                                    file_badge_deleted_fg = pink;
                                    file_badge_modified_fg = peach;
                                    file_badge_modified_bg = surface1; # "color(var(white) a(20%))"
                                    file_badge_unmerged_fg = sapphire;
                                    file_badge_unmerged_bg = surface1; # "color(var(white) a(20%))"
                                    file_badge_untracked_fg = mauve;
                                    file_badge_untracked_bg = surface1; # "color(var(white) a(20%))"
                                    file_badge_staged_fg = green;
                                    file_badge_staged_bg = surface1; # "color(var(white) a(20%))"

                                };
                                rules =
                                    (
                                        with builtins;
                                        concatLists (
                                            genList (x: [
                                                {
                                                    class = "commit_annotation";
                                                    parents = [
                                                        {
                                                            class = "commit_annotations";
                                                            attributes = [ "column_${toString (x + 1)}" ];
                                                        }
                                                    ];
                                                    border_color = "var(commit_annotation_fg_${toString x}_border)";
                                                    background_color = "var(commit_annotation_bg_inverted_${toString x})";
                                                }
                                            ]) 8
                                        )
                                    )
                                    ++ [
                                        {
                                            class = "condensed_branch_annotation_container";
                                            border_color = crust;
                                            background_color = crust;
                                        }
                                        {
                                            class = "tab_control";
                                            "layer3.opacity" = 0.0;
                                            "layer2.opacity" = 0.0;
                                            "layer2.draw_center" = false;
                                            "layer2.inner_margin" = [
                                                0
                                                0
                                                0
                                                1
                                            ];
                                            "layer2.tint" = accent;
                                        }
                                        {
                                            class = "tab_control";
                                            attributes = [ "hover" ];
                                            "layer2.opacity" = 0.5;
                                        }
                                        {
                                            class = "tab_control";
                                            attributes = [ "selected" ];
                                            "layer2.opacity" = 1.0;
                                            # File Tabs
                                        }
                                        {
                                            class = "tab_separator";
                                            "layer0.inner_margin" = [
                                                0
                                                0
                                            ];
                                            content_margin = [
                                                0
                                                0
                                                0
                                                0
                                            ];
                                        }
                                        {
                                            class = "tab";
                                            "layer0.tint" = base;
                                            "layer2.draw_center" = false;
                                            "layer2.inner_margin" = [
                                                0
                                                0
                                                0
                                                1
                                            ];
                                            "layer2.tint" = accent;
                                            "layer2.opacity" = 0.0;
                                        }
                                        {
                                            class = "tab";
                                            attributes = [ "hover" ];
                                            "layer2.opacity" = 0.5;
                                        }
                                        {
                                            class = "tab";
                                            attributes = [ "selected" ];
                                            "layer2.opacity" = 1.0;
                                        }
                                        {
                                            class = "overlay_container_control";
                                            "layer0.opacity" = 0.6;
                                            "layer0.tint" = "color(${base} l(+ 10%))";
                                        }
                                        {
                                            class = "commit_annotations";
                                            num_unique_columns = "var(commit_color_count)";
                                        }
                                        {
                                            class = "stash_annotation";
                                            color = "var(stash_ann_fg)";
                                            background_color = "var(stash_ann_bg)";
                                            border_color = "var(stash_ann_border)";
                                        }
                                        {
                                            class = "tag_annotation_icon";
                                            "layer0.opacity" = 1;
                                            "layer0.tint" = base;
                                        }
                                        {
                                            class = "tag_annotation";
                                            color = "var(tag_ann_fg)";
                                        }
                                        {
                                            class = "panel_control";
                                            parents = [ { class = "switch_project_window"; } ];
                                            "layer0.tint" = base;
                                        }
                                        {
                                            class = "tool_tip_label_control";
                                            color = text;
                                        }
                                        {
                                            class = "tool_tip_control";
                                            "layer0.tint" = base;
                                        }
                                        {
                                            class = "info_area";
                                            "layer0.opacity" = 0.5;
                                            "layer0.tint" = "var(header_button_bg)";
                                        }
                                        {
                                            class = "info_area";
                                            attributes = [ "hover" ];
                                            "layer0.opacity" = 0.75;
                                        }
                                        {
                                            class = "location_bar_heading";
                                            color = "var(location_bar_heading_fg)";
                                        }
                                        {
                                            class = "table_of_contents_heading";
                                            color = "var(table_of_contents_heading_fg)";
                                        }
                                        {
                                            class = "text_line_control";
                                            "layer0.tint" = mantle;
                                            color_scheme_tint = mantle;
                                            color_scheme_tint_2 = mantle;
                                        }
                                        {
                                            class = "search_text_control";
                                            "layer0.tint" = base;
                                        }
                                        {
                                            class = "search_help";
                                            headline_color = "var(text-light)";
                                        }
                                        {
                                            class = "quick_panel_label hint";
                                            color = overlay2;
                                        }
                                        {
                                            class = "quick_panel_label key_binding";
                                            color = overlay2;
                                        }
                                        {
                                            class = "diff_text_control";
                                            "line_selection_color" = "color(${accent}) alpha(0.05))";
                                            "line_selection_border_color" = "color(${accent}) alpha(0.5))";
                                            "line_selection_border_width" = 2.0;
                                            "line_selection_border_radius" = 2.0;
                                        }
                                        {
                                            class = "branch_stat";
                                            "layer0.tint" = overlay2;
                                        }
                                        {
                                            class = "branch_stat_label";
                                            color = text;
                                        }
                                        {
                                            class = "icon_behind";
                                            "layer0.opacity" = 1.0;
                                            "layer0.tint" = pink;
                                        }
                                        {
                                            class = "icon_ahead";
                                            "layer0.opacity" = 1.0;
                                            "layer0.tint" = green;
                                        }
                                        {
                                            class = "commit_edges_control";
                                            num_colors = "var(commit_color_count)";
                                            color0 = "var(commit_edge_0)";
                                            color1 = "var(commit_edge_1)";
                                            color2 = "var(commit_edge_2)";
                                            color3 = "var(commit_edge_3)";
                                            color4 = "var(commit_edge_4)";
                                            color5 = "var(commit_edge_5)";
                                            color6 = "var(commit_edge_6)";
                                            color7 = "var(commit_edge_7)";
                                        }
                                        {
                                            class = "blame_text_control";
                                            num_colors = 8;
                                            color0 = sapphire;
                                            color1 = mauve;
                                            color2 = pink;
                                            color3 = peach;
                                            color4 = yellow;
                                            color5 = green;
                                            color6 = red;
                                            color7 = blue;
                                        }
                                        {
                                            class = "new_badge";
                                            parents = [ { class = "file_diff_header"; } ];
                                            "layer0.tint" = red;
                                        }
                                        {
                                            class = "staged_badge";
                                            "layer0.tint" = "var(file_badge_staged_bg)";
                                        }
                                        {
                                            class = "staged_badge";
                                            parents = [ { class = "file_diff_header"; } ];
                                            "layer0.tint" = "var(file_badge_staged_bg)";
                                        }
                                        {
                                            class = "staged_badge";
                                            parents = [
                                                {
                                                    class = "file_diff_header";
                                                    attributes = [ "hover" ];
                                                }
                                            ];
                                            "layer0.tint" = "var(file_badge_staged_bg)";
                                        }
                                        {
                                            class = "modified_badge";
                                            "layer0.tint" = "var(file_badge_modified_bg)";
                                        }
                                        {
                                            class = "modified_badge";
                                            parents = [ { class = "file_diff_header"; } ];
                                            "layer0.tint" = "var(file_badge_modified_bg)";
                                        }
                                        {
                                            class = "modified_badge";
                                            parents = [
                                                {
                                                    class = "file_diff_header";
                                                    attributes = [ "hover" ];
                                                }
                                            ];
                                            "layer0.tint" = "var(file_badge_modified_bg)";
                                        }
                                        {
                                            class = "unmerged_badge";
                                            "layer0.tint" = "var(file_badge_unmerged_bg)";
                                        }
                                        {
                                            class = "unmerged_badge";
                                            parents = [ { class = "file_diff_header"; } ];
                                            "layer0.tint" = "var(file_badge_unmerged_bg)";
                                        }
                                        {
                                            class = "unmerged_badge";
                                            parents = [
                                                {
                                                    class = "file_diff_header";
                                                    attributes = [ "hover" ];
                                                }
                                            ];
                                            "layer0.tint" = "var(file_badge_unmerged_bg)";
                                        }
                                        {
                                            class = "untracked_badge";
                                            "layer0.tint" = "var(file_badge_untracked_bg)";
                                        }
                                        {
                                            class = "untracked_badge";
                                            parents = [ { class = "file_diff_header"; } ];
                                            "layer0.tint" = "var(file_badge_untracked_bg)";
                                        }
                                        {
                                            class = "untracked_badge";
                                            parents = [
                                                {
                                                    class = "file_diff_header";
                                                    attributes = [ "hover" ];
                                                }
                                            ];
                                            "layer0.tint" = "var(file_badge_untracked_bg)";
                                        }
                                        {
                                            class = "icon_created";
                                            "layer0.tint" = "var(file_badge_created_fg)";
                                        }
                                        {
                                            class = "icon_deleted";
                                            "layer0.tint" = "var(file_badge_deleted_fg)";
                                        }
                                        {
                                            class = "label_control";
                                            parents = [ { class = "modified_badge"; } ];
                                            fg = "var(file_badge_modified_fg)";
                                        }
                                        {
                                            class = "label_control";
                                            parents = [ { class = "unmerged_badge"; } ];
                                            fg = "var(file_badge_unmerged_fg)";
                                        }
                                        {
                                            class = "label_control";
                                            parents = [ { class = "untracked_badge"; } ];
                                            fg = "var(file_badge_untracked_fg)";
                                        }
                                        {
                                            class = "label_control";
                                            parents = [ { class = "staged_badge"; } ];
                                            fg = "var(file_badge_staged_fg)";
                                        }
                                        {
                                            class = "icon_deleted";
                                            parents = [ { class = "modified_badge"; } ];
                                            "layer0.tint" = "var(file_badge_deleted_fg)";
                                        }
                                        {
                                            class = "icon_unmerged";
                                            parents = [ { class = "unmerged_badge"; } ];
                                            "layer0.tint" = "var(file_badge_unmerged_fg)";
                                        }
                                        {
                                            class = "tab_label";
                                            parents = [
                                                {
                                                    class = "tab_control";
                                                    attributes = [ "selected" ];
                                                }
                                            ];
                                            fg = text;
                                        }
                                        {
                                            class = "tab_label";
                                            parents = [
                                                {
                                                    class = "tab_control";
                                                    attributes = [ "!selected" ];
                                                }
                                            ];
                                            fg = subtext0;
                                        }
                                        {
                                            class = "tab_label";
                                            parents = [
                                                {
                                                    class = "tab_control";
                                                    attributes = [
                                                        "!selected"
                                                        "hover"
                                                    ];
                                                }
                                            ];
                                            fg = subtext1;
                                        }
                                        {
                                            class = "tab_close_button";
                                            "layer0.texture" = "Theme - Default/common/tab_close.png";
                                            "layer0.tint" = overlay1;
                                            "layer0.opacity" = 0.0;
                                        }
                                        {
                                            class = "tab_close_button";
                                            parents = [
                                                {
                                                    class = "tab_control";
                                                    attributes = [ "selected" ];
                                                }
                                            ];
                                            "layer0.opacity" = 1.0;
                                        }
                                        {
                                            class = "tab_close_button";
                                            parents = [
                                                {
                                                    class = "tab_control";
                                                    attributes = [ "hover" ];
                                                }
                                            ];
                                            "layer0.opacity" = 1.0;
                                        }
                                        {
                                            class = "tab_close_button";
                                            parents = [
                                                {
                                                    class = "tab_control";
                                                    attributes = [ "dirty" ];
                                                }
                                            ];
                                            "layer0.texture" = "Theme - Merge/tab_dirty.png";
                                            "layer0.tint" = maroon;
                                            "layer0.opacity" = 1.0;
                                        }
                                        {
                                            class = "tab_close_button";
                                            "layer0.texture" = "Theme - Default/common/tab_close.png";
                                            attributes = [ "hover" ];
                                            "layer0.tint" = text;
                                            "layer0.opacity" = 1.0;
                                        }
                                        {
                                            class = "icon_folder";
                                            "layer0.texture" = "Theme - Default/common/folder_closed.png";
                                        }
                                        {
                                            class = "icon_folder";
                                            parents = [
                                                {
                                                    class = "tab_control";
                                                    attributes = [ "selected" ];
                                                }
                                            ];
                                            "layer0.texture" = "Theme - Default/common/folder_open.png";
                                            "layer0.opacity" = 1.0;
                                            "layer0.tint" = accent;
                                        }
                                        {
                                            class = "icon_folder";
                                            parents = [
                                                {
                                                    class = "tab_control";
                                                    attributes = [ "!selected" ];
                                                }
                                            ];
                                            "layer0.opacity" = 1.0;
                                            "layer0.tint" = overlay0;
                                        }
                                        {
                                            class = "icon_folder";
                                            parents = [
                                                {
                                                    class = "tab_control";
                                                    attributes = [
                                                        "!selected"
                                                        "hover"
                                                    ];
                                                }
                                            ];
                                            "layer0.opacity" = 1.0;
                                            "layer0.tint" = overlay1;
                                        }
                                    ]
                                    ++ (lib.optionals (theme.flavor != "latte") [
                                        {
                                            class = "branch_table";
                                            "dark_content" = true;
                                        }
                                        {
                                            class = "commit_table";
                                            "dark_content" = true;
                                        }
                                        {
                                            class = "scroll_track_control";
                                            parents = [ { class = "commit_table_container"; } ];
                                            "layer0.texture" = "Theme - Merge/dark_scroll_bar.png";
                                        }
                                        {
                                            class = "puck_control";
                                            parents = [ { class = "commit_table_container"; } ];
                                            "layer0.texture" = "Theme - Merge/dark_scroll_puck.png";
                                        }
                                        {
                                            class = "scroll_track_control";
                                            parents = [ { class = "side_bar_container"; } ];
                                            "layer0.texture" = "Theme - Merge/dark_scroll_bar.png";
                                        }
                                        {
                                            class = "puck_control";
                                            parents = [ { class = "side_bar_container"; } ];
                                            "layer0.texture" = "Theme - Merge/dark_scroll_puck.png";
                                        }
                                        {
                                            class = "scroll_track_control";
                                            parents = [ { class = "details_panel"; } ];
                                            "layer0.texture" = "Theme - Merge/dark_scroll_bar.png";
                                        }
                                        {
                                            class = "puck_control";
                                            parents = [ { class = "details_panel"; } ];
                                            "layer0.texture" = "Theme - Merge/dark_scroll_puck.png";
                                        }
                                        {
                                            class = "scroll_track_control";
                                            parents = [ { class = "overlay_control"; } ];
                                            "layer0.texture" = "Theme - Merge/dark_scroll_bar.png";
                                        }
                                        {
                                            class = "puck_control";
                                            parents = [ { class = "overlay_control"; } ];
                                            "layer0.texture" = "Theme - Merge/dark_scroll_puck.png";
                                        }
                                    ]);
                            };
                    };
                })
            ];
        };
    };
}
