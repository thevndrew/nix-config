{
  lib,
  mylib,
  config,
  other-pkgs,
  ...
}: let
  cfg = config.hello;
  unstable = other-pkgs.unstable;
in {
  options = {
    hello.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "TBD";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with unstable; [
      hello
    ];
  };
}