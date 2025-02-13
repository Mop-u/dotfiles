{inputs, config, pkgs, lib, target, ... }: let
    stextTop = "/home/${target.userName}/.config/sublime-text";
    stextPkg = stextTop + "/Packages";
    stextCfg = stextTop + "/Packages/User";
    smergeTop = "/home/${target.userName}/.config/sublime-merge";
    smergePkg = smergeTop + "/Packages";
    smergeCfg = smergeTop + "/Packages/User";
    catppuccinBaseName = "Catppuccin " + target.lib.capitalize target.style.catppuccin.flavor;
    catppuccinColorScheme = catppuccinBaseName + ".sublime-color-scheme";
in {

    nixpkgs.config.permittedInsecurePackages = [
        "openssl-1.1.1w"  # for sublime4 & sublime-merge :(
    ]; 

    home-manager.users.${target.userName} = {
        home.packages = with pkgs; [
            sublime4
            sublime-merge
            #inputs.veridian-nix.packages.${pkgs.system}.veridian
            #inputs.slang-lsp.packages.${pkgs.system}.slang-lsp-tools
            #svls
            #verilator
            verible
        ];
        wayland.windowManager.hyprland.settings = {
            windowrulev2 = [
                "float, class:(ssh-askpass-sublime)"
            ];
        };
        home.file = {
            # Packages
            stextPackageControl = {
                enable = true;
                target = stextPkg + "/Package Control";
                source = inputs.stextPackageControl;
            };
            stextSublimeLinterContribVerilator = {
                enable = true;
                target = stextPkg + "/SublimeLinter-contrib-verilator";
                source = inputs.stextSublimeLinterContribVerilator;
            };
            stextCatppuccin = {
                enable = true;
                target = stextPkg + "/Catppuccin color schemes";
                source = inputs.stextCatppuccin;
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
            stextSublimeLinter = {
                enable = true;
                target = stextPkg + "/SublimeLinter";
                source = inputs.stextSublimeLinter;
            };
            stextSystemVerilog = {
                enable = true;
                target = stextPkg + "/SystemVerilog";
                source = inputs.stextSystemVerilog;
            };
            # Config
            stextCfg = {
                enable = true;
                target = stextCfg + "/Preferences.sublime-settings";
                text = builtins.toJSON {
                    ignored_packages = ["Vintage"];
                    font_size = if target.text.smallTermFont then 10 else 11;
                    translate_tabs_to_spaces = true;
                    index_files = true;
                    hardware_acceleration = if target.graphics.legacyGpu then "none" else "opengl";
                    theme = "Adaptive.sublime-theme";
                    color_scheme = catppuccinColorScheme;
                    update_check = false;
                    sublime_merge_path = if target.lib.isInstalled pkgs.sublime-merge then "${pkgs.sublime-merge}/bin/sublime_merge" else null;
                };
            };
            smergeCfg = {
                enable = true;
                target = smergeCfg + "/Preferences.sublime-settings";
                text = builtins.toJSON {
                    theme = "${catppuccinBaseName}.sublime-theme";
                    translate_tabs_to_spaces = true;
                    side_bar_layout = "tabs";
                    font_size = if target.text.smallTermFont then 10 else 11;
                    hardware_acceleration = if target.graphics.legacyGpu then "none" else "opengl";
                    update_check = false;
                    editor_path = if target.lib.isInstalled pkgs.sublime4 then "${pkgs.sublime4}/bin/sublime_text" else null;
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
            stextSystemVerilogCfg = {
                enable = true;
                target = stextCfg + "/SystemVerilog.sublime-settings";
                text = builtins.toJSON {
                    "sv.disable_autocomplete" = true;
                    "sv.tooltip" = false;
                };
            };
            stextSublimeLinterCfg = {
                enable = true;
                target = stextCfg + "/SublimeLinter.sublime-settings";
                text = builtins.toJSON {
                    no_column_highlights_line = true;
                    debug = false;
                    linters = {
                        verilator = {
                            disable = target.lib.isInstalled pkgs.verilator;
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
                target = stextCfg + "/LSP.sublime-settings";
                text = builtins.toJSON {
                    clients = {
                        verilbe = {
                            enabled = target.lib.isInstalled pkgs.verible;
                            command = [
                                "verible-verilog-ls"
                                "--rules_config_search"
                            ];
                            selector = "source.systemverilog";
                        };
                        veridian = {
                            enabled = target.lib.isInstalled inputs.veridian-nix.packages.${pkgs.system}.veridian;
                            command = ["veridian"];
                            selector = "source.systemverilog";
                        };
                        nil = {
                            enabled = target.lib.isInstalled pkgs.nil;
                            command = ["nil"];
                            selector = "source.nix";
                            # https://github.com/oxalica/nil/blob/main/docs/configuration.md
                            settings = {
                                nil.nix.flake = {
                                    autoArchive = true;
                                    autoEvalInputs = true;
                                };
                            };
                        };
                        slang = {
                            enabled = target.lib.isInstalled inputs.slang-lsp.packages.${pkgs.system}.slang-lsp-tools;
                            command = ["slang-lsp"];
                            selector = "source.systemverilog";
                        };
                        svls = {
                            enabled = target.lib.isInstalled pkgs.svls;
                            command = ["svls"];
                            selector = "source.systemverilog";
                        };
                    };
                };
            };
            # based on https://github.com/bitsper2nd/merge-mariana-theme
            smergeThemeOverride = {
                enable = true;
                target = smergeCfg + "/${catppuccinBaseName}.sublime-theme";
                text = builtins.toJSON {
                    extends = "Merge.sublime-theme";
                    variables = {
                        rosewater = "#" + target.style.catppuccin.rosewater.hex;
                        flamingo  = "#" + target.style.catppuccin.flamingo.hex;
                        pink      = "#" + target.style.catppuccin.pink.hex;
                        mauve     = "#" + target.style.catppuccin.mauve.hex;
                        red       = "#" + target.style.catppuccin.red.hex;
                        maroon    = "#" + target.style.catppuccin.maroon.hex;
                        peach     = "#" + target.style.catppuccin.peach.hex;
                        yellow    = "#" + target.style.catppuccin.yellow.hex;
                        green     = "#" + target.style.catppuccin.green.hex;
                        teal      = "#" + target.style.catppuccin.teal.hex;
                        sky       = "#" + target.style.catppuccin.sky.hex;
                        sapphire  = "#" + target.style.catppuccin.sapphire.hex;
                        blue      = "#" + target.style.catppuccin.blue.hex;
                        lavender  = "#" + target.style.catppuccin.lavender.hex;
                        text      = "#" + target.style.catppuccin.text.hex;
                        subtext1  = "#" + target.style.catppuccin.subtext1.hex;
                        subtext0  = "#" + target.style.catppuccin.subtext0.hex;
                        overlay2  = "#" + target.style.catppuccin.overlay2.hex;
                        overlay1  = "#" + target.style.catppuccin.overlay1.hex;
                        overlay0  = "#" + target.style.catppuccin.overlay0.hex;
                        surface2  = "#" + target.style.catppuccin.surface2.hex;
                        surface1  = "#" + target.style.catppuccin.surface1.hex;
                        surface0  = "#" + target.style.catppuccin.surface0.hex;
                        base      = "#" + target.style.catppuccin.base.hex;
                        mantle    = "#" + target.style.catppuccin.mantle.hex;
                        crust     = "#" + target.style.catppuccin.crust.hex;
                        highlight = "#" + target.style.catppuccin.highlight.hex;

                        white = "hsl(0, 0%, 95%)";
                        text-heading = "var(subtext1)";
                        text-light = "var(subtext0)";#"color(var(text) a(- 40%))"
                        darken = "hsl(0, 0%, 13%)";

                        orange = "var(peach)";
                        cyan = "var(sapphire)";
                        purple = "var(mauve)";

                        # Alias for pink
                        magenta = "var(pink)";
                        dark_red = "color(var(red) s(25%) l(35%))";
                        dark_blue = "color(var(blue) s(25%) l(35%))";

                        # Labels
                        label_color = "var(text-heading)";
                        help_label_color = "var(text-light)";#"color(var(text-heading) a(0.6))";

                        # Header
                        title_bar_style = "dark";
                        header_bg = "var(base)";
                        header_fg = "var(text-heading)";
                        header_button_bg = "var(surface1)";#"color(var(base) l(25%))";
                        icon_button_fg = "var(text)";

                        info_shadow = "color(black a(0.2))";

                        diverged_bg = "color(var(orange) l(- 5%) s(- 20%))";
                        diverged_button_bg = "var(button_bg)";
                        diverged_button_fg = "var(base)";

                        # Scroll shadow
                        scroll_shadow = "color(black a(0.3))";

                        # Focus highlight
                        focus_highlight_color = "var(text)";

                        # Welcome overlay
                        welcome_bg = "color(var(base) l(- 5%))";
                        recent_repositories_row_bg-hover = "color(var(base) l(+ 5%))";

                        # Preferences Page
                        preferences_overlay_bg = "color(var(base) l(+ 5%))";
                        preferences_section_table_bg = "var(base)";

                        # Side bar
                        location_bar_fg = "var(text)";
                        location_bar_heading_fg = "var(text-heading)";
                        location_bar_heading_shadow = "black";
                        location_bar_row_bg-hover = "color(var(base) l(+ 30%) a(0.25))";
                        disclosure_fg = "var(text)";

                        # Commit list
                        commit_list_bg = "var(mantle)";
                        commit_row_bg-hover = "var(base)";
                        commit_summary_fg-primary = "var(text-heading)";
                        commit_summary_fg-secondary = "var(text-light)";
                        commit_color_count = 8;

                        commit_edge_0 = "var(blue)";
                        commit_edge_1 = "var(purple)";
                        commit_edge_2 = "var(pink)";
                        commit_edge_3 = "var(orange)";
                        commit_edge_4 = "var(yellow)";
                        commit_edge_5 = "var(green)";
                        commit_edge_6 = "var(red)";
                        commit_edge_7 = "var(cyan)";

                        # Annotations
                        commit_annotation_fg = "var(base)";
                        commit_annotation_fg_inverted = "var(base)";
                        commit_annotation_bg = "var(cyan)";

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
                        side_bar_container_bg = "var(base)";

                        # Table of Contents
                        table_of_contents_bg = "color(var(base) l(+ 3%))";
                        table_of_contents_fg = "var(text)";
                        table_of_contents_heading_fg = "var(text-heading)";
                        table_of_contents_row_bg = "color(var(base) l(+ 30%))";

                        # Detail panel
                        detail_panel_bg = "var(base)";
                        field_name_fg = "var(text)";
                        author_fg = "var(overlay2)";#"color(var(white) a(0.4))";
                        terminator_fg = "var(text)";

                        remote_ann_fg = "color(var(base) a(0.7))";
                        remote_ann_bg = "var(green)";

                        stash_ann_fg = "var(text)";
                        stash_ann_bg = "var(surface1)";#"color(var(white) a(20%))"
                        stash_ann_border = "var(overlay2)";#"color(var(white) a(50%))";

                        tag_ann_fg = "var(base)";
                        tag_ann_bg = "var(yellow)";
                        tag_ann_opacity = 0.4;

                        file_ann_fg = "var(base)";
                        file_ann_bg = "var(blue)";

                        submodule_ann_fg = "var(text)";
                        submodule_ann_bg = "var(surface1)";#"color(var(white) a(20%))"
                        submodule_light_ann_fg = "var(text)";
                        submodule_light_ann_bg = "var(surface1)";#"color(var(white) a(20%))"

                        inserted_ann_bg = "color(var(green) a(0.50))";
                        deleted_ann_bg = "color(var(red) a(0.50))";

                        # Diff headers
                        file_diff_shadow = "color(black a(0.5))";
                        file_icon_bg = "color(var(text) a(0.2))";

                        hunk_button_fg = "var(text)";
                        hunk_button_shadow = "color(black a(0.5))";

                        file_header_bg = "var(surface0)";#"color(var(base) l(+ 5%))";
                        file_header_bg-hover = "var(surface1)";#"color(var(base) l(+ 10%))";

                        hunk_header_bg = "var(base)";#"color(var(base) l(+ 12%))";

                        deleted_icon_fg = "var(text)";
                        deleted_header_bg = "var(red)";
                        deleted_header_bg-hover = "color(var(red) l(+ 5%))";

                        unmerged_icon_fg = "var(text)";
                        unmerged_header_bg = "var(blue)";
                        unmerged_header_bg-hover = "color(var(blue) l(+ 3%))";

                        recent_icon_fg = "var(yellow)";
                        recent_icon_bg = "transparent";
                        untracked_header_bg = "var(surface0)";#"color(var(base) s(- 5%) l(+ 15%))";
                        untracked_header_bg-hover = "var(surface1)";#"color(var(untracked_header_bg) l(+ 5%))";

                        full_context_icon_bg = "var(text)";

                        staged_icon_fg = "var(text)";

                        renamed_file_inserted = "color(var(green) s(30%) l(60%))";
                        renamed_file_deleted = "color(var(red) s(50%) l(65%))";

                        # Blame
                        blame_popup_bg = "var(surface0)";

                        # Buttons
                        button_bg = "var(overlay0)";#"color(var(white) a(20%))"
                        button_fg = "var(label_color)";
                        button_shadow = "color(black a(0.5))";

                        highlighted_button_light_bg = "color(var(green) a(75%))";
                        highlighted_button_light_fg = "var(text)";
                        highlighted_button_dark_bg = "color(var(green) a(75%))";
                        highlighted_button_dark_fg = "var(text)";
                        highlighted_button_shadow = "color(black a(0.5) l(+ 10%))";

                        toggle_button_bg = "var(overlay0)";#"color(var(white) a(20%))" # This matches the header hover buttons
                        toggle_button_fg = "var(text)";
                        toggle_button_fg_selected = "var(text-heading)";

                        # Tabs
                        tab_bar_bg = "var(base)";
                        tab_separator_bg = "var(base)";

                        # Radio buttons
                        radio_back = "var(base)";
                        radio_selected = "var(highlight)";
                        radio_border-selected = "var(highlight)";

                        # Checkbox buttons
                        checkbox_back = "var(base)";
                        checkbox_selected = "var(highlight)";
                        checkbox_border-selected = "var(highlight)";

                        # Dialogs
                        dialog_bg = "var(base)";
                        dialog_button_bg = "var(overlay0)";#"color(var(white) a(20%))"

                        # Progress bar
                        progress_bg = "var(header_button_bg)";
                        progress_fg = "color(var(highlight))";

                        # Quick panel
                        quick_panel_bg = "var(base)";
                        quick_panel_row_bg = "var(surface0)";
                        quick_panel_fg = "var(text)";
                        quick_panel_fg-match = "var(highlight)";
                        quick_panel_fg-selected = "var(text)";
                        quick_panel_fg-selected-match = "var(highlight)";
                        quick_panel_path_fg = "var(text-light)";
                        quick_panel_path_fg-match = "var(highlight)";
                        quick_panel_path_fg-selected = "var(text-light)";
                        quick_panel_path_fg-selected-match = "var(highlight)";

                        switch_repo_bg = "var(base)";

                        # Image Diffs
                        image_diff_checkerboard_alt_bg = "var(surface0)";
                        image_metadata_label_bg = "var(surface1)";

                        # Hints
                        failed_label_fg = "var(base)";

                        # Loading
                        loading_ball_1 = "var(pink)";
                        loading_ball_2 = "var(green)";

                        # Command Palette
                        preview_fg = "white";

                        # Merge Helper
                        merge_helper_highlight_bg = "var(surface1)";
                        console_border = "color(var(base) l(+ 10%))";

                        # Tabs
                        repository_tab_bar_bg = "var(base)";
                        repository_tab_bar_border_bg = "var(base)";

                        file_badge_created_fg = "var(green)";
                        file_badge_deleted_fg = "var(pink)";
                        file_badge_modified_fg = "var(orange)";
                        file_badge_modified_bg = "var(surface1)";#"color(var(white) a(20%))"
                        file_badge_unmerged_fg = "var(cyan)";
                        file_badge_unmerged_bg = "var(surface1)";#"color(var(white) a(20%))"
                        file_badge_untracked_fg = "var(purple)";
                        file_badge_untracked_bg = "var(surface1)";#"color(var(white) a(20%))"
                        file_badge_staged_fg = "var(green)";
                        file_badge_staged_bg = "var(surface1)";#"color(var(white) a(20%))"

                    };
                    rules = [
                        {
                            class = "tab_control";
                            "layer3.opacity" = 0.0;
                            "layer2.opacity" = 0.0;
                            "layer2.draw_center" = false;
                            "layer2.inner_margin" = [0 0 0 1];
                            "layer2.tint" = "var(highlight)";
                        }{
                            class = "tab_control";
                            attributes = ["hover"];
                            "layer2.opacity" = 0.5;
                        }{
                            class = "tab_control";
                            attributes = ["selected"];
                            "layer2.opacity" = 1.0;
                        # File Tabs
                        }{
                            class = "tab_separator";
                            "layer0.inner_margin" = [0 0];
                            content_margin = [0 0 0 0];
                        }{
                            class = "tab";
                            "layer0.tint" = "var(base)";
                            "layer2.draw_center" = false;
                            "layer2.inner_margin" = [0 0 0 1];
                            "layer2.tint" = "var(highlight)";
                            "layer2.opacity" = 0.0;
                        }{
                            class = "tab";
                            attributes = ["hover"];
                            "layer2.opacity" = 0.5;
                        }{
                            class = "tab";
                            attributes = ["selected"];
                            "layer2.opacity" = 1.0;
                        }{
                            class = "overlay_container_control";
                            "layer0.opacity" = 0.6;
                            "layer0.tint" = "color(var(base) l(+ 10%))";
                        }{
                            class = "commit_annotations";
                            num_unique_columns = "var(commit_color_count)";
                        }{
                            class = "commit_annotation bordered";
                            parents = [{class = "commit_annotations"; attributes = ["column_7"];}];
                            border_color = "var(commit_annotation_fg_6_border)";
                        }{
                            class = "commit_annotation branch head";
                            parents = [{class = "commit_annotations"; attributes = ["column_7"];}];
                            background_color = "var(commit_annotation_bg_inverted_6)";
                        }{
                            class = "commit_annotation bordered";
                            parents = [{class = "commit_annotations"; attributes = ["column_8"];}];
                            border_color = "var(commit_annotation_fg_7_border)";
                        }{
                            class = "commit_annotation branch head";
                            parents = [{class = "commit_annotations"; attributes = ["column_8"];}];
                            background_color = "var(commit_annotation_bg_inverted_7)";
                        }{
                            class = "stash_annotation";
                            color = "var(stash_ann_fg)";
                            background_color = "var(stash_ann_bg)";
                            border_color = "var(stash_ann_border)";
                        }{
                            class = "tag_annotation_icon";
                            "layer0.opacity" = 1;
                            "layer0.tint" = "var(base)";
                        }{
                            class = "tag_annotation";
                            color = "var(tag_ann_fg)";
                        }{
                            class = "panel_control";
                            parents = [{class = "switch_project_window";}];
                            "layer0.tint" = "var(base)";
                        }{
                            class = "tool_tip_label_control";
                            color = "var(text)";
                        }{
                            class = "tool_tip_control";
                            "layer0.tint" = "var(base)";
                        }{
                            class = "info_area";
                            "layer0.opacity" = 0.5;
                            "layer0.tint" = "var(header_button_bg)";
                        }{
                            class = "info_area";
                            attributes = ["hover"];
                            "layer0.opacity" = 0.75;
                        }{
                            class = "location_bar_heading";
                            color = "var(location_bar_heading_fg)";
                        }{
                            class = "table_of_contents_heading";
                            color = "var(table_of_contents_heading_fg)";
                        }{
                            class = "text_line_control";
                            "layer0.tint" = "var(mantle)";
                            color_scheme_tint = "var(mantle)";
                            color_scheme_tint_2 = "var(mantle)";
                        }{
                            class = "search_text_control";
                            "layer0.tint" = "var(base)";
                        }{
                            class = "search_help";
                            headline_color = "var(text-light)";
                        }{
                            class = "quick_panel_label hint";
                            color = "var(overlay2)";
                        }{
                            class = "quick_panel_label key_binding";
                            color = "var(overlay2)";
                        }{
                            class = "diff_text_control";
                            "line_selection_color" = "color(var(highlight) alpha(0.05))";
                            "line_selection_border_color" = "color(var(highlight) alpha(0.5))";
                            "line_selection_border_width" = 2.0;
                            "line_selection_border_radius" = 2.0;
                        }{
                            class = "branch_stat";
                            "layer0.tint" = "var(overlay2)";
                        }{
                            class = "branch_stat_label";
                            color = "var(text)";
                        }{
                            class = "icon_behind";
                            "layer0.opacity" = 1.0;
                            "layer0.tint" = "var(pink)";
                        }{
                            class = "icon_ahead";
                            "layer0.opacity" = 1.0;
                            "layer0.tint" = "var(green)";
                        }{
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
                        }{
                            class = "blame_text_control";
                            num_colors = 8;
                            color0 = "var(cyan)";
                            color1 = "var(purple)";
                            color2 = "var(pink)";
                            color3 = "var(orange)";
                            color4 = "var(yellow)";
                            color5 = "var(green)";
                            color6 = "var(red)";
                            color7 = "var(blue)";
                        }{
                            class = "new_badge";
                            parents = [{class = "file_diff_header";}];
                            "layer0.tint" = "var(red)";
                        }{
                            class = "staged_badge";
                            "layer0.tint" = "var(file_badge_staged_bg)";
                        }{
                            class = "staged_badge";
                            parents = [{class = "file_diff_header";}];
                            "layer0.tint" = "var(file_badge_staged_bg)";
                        }{
                            class = "staged_badge";
                            parents = [{class = "file_diff_header"; attributes = ["hover"];}];
                            "layer0.tint" = "var(file_badge_staged_bg)";
                        }{
                            class = "modified_badge";
                            "layer0.tint" = "var(file_badge_modified_bg)";
                        }{
                            class = "modified_badge";
                            parents = [{class = "file_diff_header";}];
                            "layer0.tint" = "var(file_badge_modified_bg)";
                        }{
                            class = "modified_badge";
                            parents = [{class = "file_diff_header"; attributes = ["hover"];}];
                            "layer0.tint" = "var(file_badge_modified_bg)";
                        }{
                            class = "unmerged_badge";
                            "layer0.tint" = "var(file_badge_unmerged_bg)";
                        }{
                            class = "unmerged_badge";
                            parents = [{class = "file_diff_header";}];
                            "layer0.tint" = "var(file_badge_unmerged_bg)";
                        }{
                            class = "unmerged_badge";
                            parents = [{class = "file_diff_header"; attributes = ["hover"];}];
                            "layer0.tint" = "var(file_badge_unmerged_bg)";
                        }{
                            class = "untracked_badge";
                            "layer0.tint" = "var(file_badge_untracked_bg)";
                        }{
                            class = "untracked_badge";
                            parents = [{class = "file_diff_header";}];
                            "layer0.tint" = "var(file_badge_untracked_bg)";
                        }{
                            class = "untracked_badge";
                            parents = [{class = "file_diff_header"; attributes = ["hover"];}];
                            "layer0.tint" = "var(file_badge_untracked_bg)";
                        }{
                            class = "icon_created";
                            "layer0.tint" = "var(file_badge_created_fg)";
                        }{
                            class = "icon_deleted";
                            "layer0.tint" = "var(file_badge_deleted_fg)";
                        }{
                            class = "label_control";
                            parents = [{class = "modified_badge";}];
                            fg = "var(file_badge_modified_fg)";
                        }{
                            class = "label_control";
                            parents = [{class = "unmerged_badge";}];
                            fg = "var(file_badge_unmerged_fg)";
                        }{
                            class = "label_control";
                            parents = [{class = "untracked_badge";}];
                            fg = "var(file_badge_untracked_fg)";
                        }{
                            class = "label_control";
                            parents = [{class = "staged_badge";}];
                            fg = "var(file_badge_staged_fg)";
                        }{
                            class = "icon_deleted";
                            parents = [{class = "modified_badge";}];
                            "layer0.tint" = "var(file_badge_deleted_fg)";
                        }{
                            class = "icon_unmerged";
                            parents = [{class = "unmerged_badge";}];
                            "layer0.tint" = "var(file_badge_unmerged_fg)";
                        }{
                            class = "tab_label";
                            parents = [{class = "tab_control"; attributes = ["selected"];}];
                            fg = "var(text)";
                        }{
                            class = "tab_label";
                            parents = [{class = "tab_control"; attributes = ["!selected"];}];
                            fg = "var(subtext0)";
                        }{
                            class = "tab_label";
                            parents = [{class = "tab_control"; attributes = ["!selected" "hover"];}];
                            fg = "var(subtext1)";
                        }{
                            class = "tab_close_button";
                            "layer0.texture" = "Theme - Default/common/tab_close.png";
                            "layer0.tint" = "var(overlay1)";
                            "layer0.opacity" = 0.0;
                        }{
                            class = "tab_close_button";
                            parents = [{class = "tab_control"; attributes = ["selected"];}];
                            "layer0.opacity" = 1.0;
                        }{
                            class = "tab_close_button";
                            parents = [{class = "tab_control"; attributes = ["hover"];}];
                            "layer0.opacity" = 1.0;
                        }{
                            class = "tab_close_button";
                            parents = [{class = "tab_control"; attributes = ["dirty"];}];
                            "layer0.texture" = "Theme - Merge/tab_dirty.png";
                            "layer0.tint" = "var(maroon)";
                            "layer0.opacity" = 1.0;
                        }{
                            class = "tab_close_button";
                            "layer0.texture" = "Theme - Default/common/tab_close.png";
                            attributes = ["hover"];
                            "layer0.tint" = "var(text)";
                            "layer0.opacity" = 1.0;
                        }{
                            class = "icon_folder";
                            "layer0.texture" = "Theme - Default/common/folder_closed.png";
                        }{
                            class = "icon_folder";
                            parents = [{class = "tab_control"; attributes = ["selected"];}];
                            "layer0.texture" = "Theme - Default/common/folder_open.png";
                            "layer0.opacity" = 1.0;
                            "layer0.tint" = "var(highlight)";
                        }{
                            class = "icon_folder";
                            parents = [{class = "tab_control"; attributes = ["!selected"];}];
                            "layer0.opacity" = 1.0;
                            "layer0.tint" = "var(overlay0)";
                        }{
                            class = "icon_folder";
                            parents = [{class = "tab_control"; attributes = ["!selected" "hover"];}];
                            "layer0.opacity" = 1.0;
                            "layer0.tint" = "var(overlay1)";
                        }
                    ] ++ (if target.style.catppuccin.flavor == "latte" then [] else [
                        {
                            class = "branch_table";
                            "dark_content" = true;
                        }{
                            class = "commit_table";
                            "dark_content" = true;
                        }{
                            class = "scroll_track_control";
                            parents = [{class = "commit_table_container";}];
                            "layer0.texture" = "Theme - Merge/dark_scroll_bar.png";
                        }{
                            class = "puck_control";
                            parents = [{class = "commit_table_container";}];
                            "layer0.texture" = "Theme - Merge/dark_scroll_puck.png";
                        }{
                            class = "scroll_track_control";
                            parents = [{class = "side_bar_container";}];
                            "layer0.texture" = "Theme - Merge/dark_scroll_bar.png";
                        }{
                            class = "puck_control";
                            parents = [{class = "side_bar_container";}];
                            "layer0.texture" = "Theme - Merge/dark_scroll_puck.png";
                        }{
                            class = "scroll_track_control";
                            parents = [{class = "details_panel";}];
                            "layer0.texture" = "Theme - Merge/dark_scroll_bar.png";
                        }{
                            class = "puck_control";
                            parents = [{class = "details_panel";}];
                            "layer0.texture" = "Theme - Merge/dark_scroll_puck.png";
                        }{
                            class = "scroll_track_control";
                            parents = [{class = "overlay_control";}];
                            "layer0.texture" = "Theme - Merge/dark_scroll_bar.png";
                        }{
                            class = "puck_control";
                            parents = [{class = "overlay_control";}];
                            "layer0.texture" = "Theme - Merge/dark_scroll_puck.png";
                        }
                    ]);
                };
            };
        };
    };
}
