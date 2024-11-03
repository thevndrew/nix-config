{moduleNamespace, ...}: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.${moduleNamespace}.gui-system.hello;
in {
  _file = ./hello.nix;

  options = {
    ${moduleNamespace}.gui-system.hello.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "TBD";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs.unstable; [
      hello
    ];
  };
}
