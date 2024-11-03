{
  lib,
  config,
  pkgs,
  inputs,
  isDesktop,
  isWSL,
  user,
  hostname,
  ...
}: let
  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDhkI3pjA6Wlpqg/cycwov3VXXbivbBMXDzUyxIyYwJF polar-tang"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKjhR4i/ce5HZ/W2tEJsbEJL2754R5H24bPD3cBxdWEP thousand-sunny"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINGqG13rubr95t6Yepq745+TxYtyqR50BZhR33eDtlUX going-merry"
  ];
  wslPass = "$6$90MQYhLKTQJ71Zw9$WrsMNytjnVmZcKNwuWg3grXPsfC2LTw5wt7QGcHc9A5fJUIhskOhJd1L0s.E.VRgpzeuckuEgrojxqqkch51V0";
in {
  disabledModules = [];

  imports = [
    # "${inputs.nixpkgs-unstable}/nixos/modules/..."
  ];

  cockpit.enable = !isWSL;
  gui.enable = isDesktop;
  wsl-cfg.enable = isWSL;

  networking.samba.sharing.enable = !isWSL;
  networking.samba.storage.enable = hostname == "thousand-sunny";

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  time.timeZone = "America/New_York";

  fonts.enableDefaultPackages = true;

  programs = {
    zsh.enable = true;

    nh = {
      enable = true;
      package = pkgs.unstable.nh;
      clean = {
        enable = true;
        dates = "weekly";
        extraArgs = "--keep 3 --keep-since 7d";
      };
      flake = "/home/${user}/nix-config";
    };
  };

  #nixpkgs.overlays = import ../../lib/overlays.nix ++ [
  #  (import ./vim.nix { inherit inputs; })
  #];
  environment = {
    enableAllTerminfo = true;

    # Add ~/.local/bin to PATH
    localBinInPath = true;

    pathsToLink = [
      "/share/bash-completion"
      "/share/zsh"
    ];

    shells = [pkgs.zsh];

    systemPackages = with pkgs; [
      mergerfs
      tmux
      neovim
      git
      ethtool
    ];
  };

  nix = {
    registry = {
      nixpkgs = {
        flake = inputs.nixpkgs;
      };
    };

    nixPath = [
      "nixpkgs=${inputs.nixpkgs.outPath}"
    ];

    optimise = {
      automatic = true;
      dates = ["daily"];
    };

    settings = {
      accept-flake-config = true;
      auto-optimise-store = true;
      builders-use-substitutes = true;

      experimental-features = ["nix-command" "flakes"];

      substituters = [
        "https://nix-community.cachix.org"
      ];

      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      extra-substituters = [
        "https://anyrun.cachix.org"
        "https://hyprland.cachix.org"
      ];

      extra-trusted-public-keys = [
        "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];

      warn-dirty = false;
    };

    gc = {
      automatic = false; # using nh clean instead
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  programs.nix-ld.enable = true;

  services = {
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.PermitRootLogin = "yes";
      ports = [22 2222];
    };

    tailscale = {
      enable = true;
      package = pkgs.unstable.tailscale;
      useRoutingFeatures = "both";
    };

    vnstat.enable = true;

    resolved = {
      enable = false;
      fallbackDns = [
        "100.100.100.100"
        "9.9.9.9"
      ];
      domains = [
        "ainu-kanyu.ts.net"
      ];
    };
  };

  sops = lib.mkIf (!isWSL) {
    defaultSopsFile = "${inputs.mysecrets}/secrets/nix.yaml";
    age.sshKeyPaths = "/home/${user}/.ssh/${hostname}";
    secrets."passwords/${user}" = {
      neededForUsers = true;
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
}
