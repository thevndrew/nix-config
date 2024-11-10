{moduleNamespace, ...}: {
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.${moduleNamespace}.cockpit;
in {
  _file = ./default.nix;

  options = {
    ${moduleNamespace}.cockpit.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "Enable and configure Cockpit";
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      cockpit = {
        enable = true;
        package = pkgs.unstable.cockpit;
        port = 8085;
      };
    };
    environment.systemPackages = [
      pkgs.vndrew.cockpit-podman
    ];
  };
}
