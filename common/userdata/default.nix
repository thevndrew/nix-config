{
  inputs,
  lib,
  isWSL,
  config,
  ...
}: pkgs: let
  user = "andrew";
  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDhkI3pjA6Wlpqg/cycwov3VXXbivbBMXDzUyxIyYwJF polar-tang"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKjhR4i/ce5HZ/W2tEJsbEJL2754R5H24bPD3cBxdWEP thousand-sunny"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINGqG13rubr95t6Yepq745+TxYtyqR50BZhR33eDtlUX going-merry"
  ];
  wslPass = "$6$90MQYhLKTQJ71Zw9$WrsMNytjnVmZcKNwuWg3grXPsfC2LTw5wt7QGcHc9A5fJUIhskOhJd1L0s.E.VRgpzeuckuEgrojxqqkch51V0";
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
    };
  };

  users.groups = {
    users.gid = 100;
    #storage.gid = ???;
  };

  users = {
    mutableUsers = false;
    users.${user} =
      {
        home = "/home/${user}";
        shell = pkgs.zsh;
        isNormalUser = true;
        openssh.authorizedKeys.keys = keys;
        uid =
          if !isWSL
          then 1001
          else lib.mkForce 1001;
      }
      // lib.optionalAttrs (!isWSL) {
        hashedPasswordFile = config.sops.secrets."passwords/${user}".path;
      }
      // lib.optionalAttrs isWSL {
        hashedPassword = wslPass;
      };

    users.root =
      {
        openssh.authorizedKeys.keys = keys;
      }
      // lib.optionalAttrs (!isWSL) {
        hashedPasswordFile = config.sops.secrets."passwords/${user}".path;
      }
      // lib.optionalAttrs isWSL {
        hashedPassword = wslPass;
      };
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
