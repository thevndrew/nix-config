{
  moduleNamespace,
  inputs,
  ...
}: {
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.${moduleNamespace}.wol;
in {
  _file = ./default.nix;
  options = {
    ${moduleNamespace}.wol = {
      enable = lib.mkEnableOption "wol systemd service";
      wolCommand = lib.mkOption {
        default = "echo I'm not configured correctly, check your nix config and set the wolCommand option";
        type = lib.types.bool;
      };
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services.wol = {
      enable = true;
      description = "Wake-on-LAN service";
      path = [pkgs.ethtool];
      after = ["network.target"];
      requires = ["network.target"];
      unitConfig = {
        Type = "oneshot";
      };
      serviceConfig = {
        ExecStart = "/bin/sh -c '${cfg.wolCommand}'";
      };
      wantedBy = ["multi-user.target"];
    };
  };
}
