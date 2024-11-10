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
  cfg = config.${moduleNamespace}.wsl;
in {
  imports = [
    inputs.nixos-wsl.nixosModules.default
  ];

  _file = ./default.nix;

  options = {
    ${moduleNamespace}.wsl = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Configure defaults for WSL-based systems";
      };
      user = lib.mkOption {
        type = lib.types.str;
        description = "User for the WSL instance";
        default = throw "Must set the user option when using the wsl.nix module";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    wsl = {
      enable = true;

      defaultUser = cfg.user;
      docker-desktop.enable = true;

      extraBin = with pkgs; [
        # Binaries for Docker Desktop wsl-distro-proxy
        {src = "${coreutils}/bin/mkdir";}
        {src = "${coreutils}/bin/cat";}
        {src = "${coreutils}/bin/whoami";}
        {src = "${coreutils}/bin/ls";}
        {src = "${busybox}/bin/addgroup";}
        {src = "${su}/bin/groupadd";}
        {src = "${su}/bin/usermod";}
      ];

      startMenuLaunchers = true;

      wslConf = {
        automount = {
          root = "/mnt";
          options = "metadata,uid=1001,gid=100";
        };
        interop.appendWindowsPath = false;
        network.generateHosts = false;
      };
    };
  };
}
