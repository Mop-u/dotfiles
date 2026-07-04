{
  osConfig,
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.helix = {
    extraPackages = with pkgs; [
      slang-server # verilog/systemverilog
      verible # verilog formatter
    ];
    languages = {
      language-server = {
        slang-server.command = "slang-server";
      };
      language =
        map
          (
            x:
            rec {
              language-servers = [
                {
                  name = "slang-server";
                  except-features = [ "format" ];
                }
              ];
              indent = {
                tab-width = 4;
                unit = "    ";
              };
              formatter = {
                command = "verible-verilog-format";
                args =
                  (lib.mapAttrsToList
                    (
                      n: v:
                      let
                        stringified = if builtins.isBool v then if v == true then "true" else "false" else toString v;
                      in
                      "--${n}=${stringified}"
                    )
                    {
                      column_limit = 120;
                      indentation_spaces = indent.tab-width;
                      wrap_end_else_clauses = true;
                      formal_parameters_indentation = "indent";
                      named_port_indentation = "indent";
                      named_parameter_indentation = "indent";
                      port_declarations_indentation = "indent";
                      assignment_statement_alignment = "align";
                      case_items_alignment = "align";
                      class_member_variable_alignment = "align";
                      distribution_items_alignment = "align";
                      enum_assignment_statement_alignment = "align";
                      formal_parameters_alignment = "align";
                      module_net_variable_alignment = "align";
                      named_parameter_alignment = "align";
                      named_port_alignment = "align";
                      port_declarations_alignment = "align";
                      struct_union_members_alignment = "align";
                      port_declarations_right_align_packed_dimensions = false;
                      port_declarations_right_align_unpacked_dimensions = false;
                    }
                  )
                  ++ [ "-" ];
              };
            }
            // x
          )
          [
            {
              name = "verilog";
              file-types = [
                "v"
                "vh"
              ];
            }
            {
              name = "systemverilog";
              file-types = [
                "sv"
                "svh"
              ];
            }
          ];
    };
  };
}
