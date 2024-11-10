{
  inputs,
  lib,
  ...
}: {
  pkgs,
  config,
}: let
  user = "andrew";
  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDhkI3pjA6Wlpqg/cycwov3VXXbivbBMXDzUyxIyYwJF polar-tang"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKjhR4i/ce5HZ/W2tEJsbEJL2754R5H24bPD3cBxdWEP thousand-sunny"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINGqG13rubr95t6Yepq745+TxYtyqR50BZhR33eDtlUX going-merry"
  ];
in rec {
  users = {
    andrew = {
      name = "andrew";
      shell = pkgs.zsh;
      isNormalUser = true;
      description = "";
      extraGroups = ["networkmanager" "wheel" "podman" "storage" "docker" "vboxusers" "input"];
      # this is packages for nixOS user config.
      # packages = []; # empty because that is managed by home-manager
      openssh.authorizedKeys.keys = keys;
      uid = 1001;
      hashedPasswordFile = config.sops.secrets."passwords/${user}".path;
    };

    root = {
      openssh.authorizedKeys.keys = keys;
      hashedPasswordFile = config.sops.secrets."passwords/${user}".path;
    };
  };

  mutableUsers = false;

  groups = {
    users.gid = 100;
    #storage.gid = ???;
  };

  git = {
    andrew = {
      extraConfig = {
        core = {
          autoSetupRemote = "true";
          fsmonitor = "true";
        };
      };
      userName = "andrew";
    };
  };

  homeManager = {
    andrew = mkHMdir "andrew";
  };

  mkHMdir = username: let
    homeDirPrefix =
      if pkgs.stdenv.hostPlatform.isDarwin
      then "Users"
      else "home";
    homeDirectory = "/${homeDirPrefix}/${username}";
  in {
    inherit username homeDirectory;
  };
}
