{
  moduleNamespace,
  inputs,
  ...
}: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.${moduleNamespace}.terminals;
  inherit (pkgs) unstable;
in {
  _file = ./default.nix;

  options = {
    ${moduleNamespace}.terminals = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Install and configure terminals";
      };

      wezterm = lib.mkOption {
        type = lib.types.bool;
        default = cfg.enable;
        example = false;
        description = "Install and configure wezterm";
      };

      alacritty = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Install and configure alacritty";
      };

      kitty = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Install and configure kitty";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.wezterm = {
      enable = cfg.wezterm;
      package = inputs.wezterm.packages.${pkgs.system}.default;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
    programs.alacritty = {
      enable = cfg.alacritty;
      package = unstable.alacritty;
    };
    programs.kitty = {
      enable = cfg.kitty;
      package = unstable.kitty;
      #font = {
      #  name = "";
      #  size = 12;
      #  package = ;
      #};
      shellIntegration = {
        enableBashIntegration = true;
        enableZshIntegration = true;
      };
    };
  };
}
