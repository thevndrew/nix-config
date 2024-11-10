# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  modulesPath,
  config,
  lib,
  pkgs,
  self,
  inputs,
  stateVersion,
  users,
  username,
  hostname,
  system-modules,
  ...
}: {
  imports = with system-modules; [
    # vndrew-nvim
    # alacritty
    # shell.bash
    # shell.zsh
    cockpit
    networking
    samba
    virtualisation
    wol
    wsl
    LD
  ];

  users.users =
    lib.recursiveUpdate users.users
    {
      ${username}.hashedPasswordFile = config.sops.secrets."passwords/${username}".path;
      root.hashedPasswordFile = config.sops.secrets."passwords/${username}".path;
    };

  vndrewMods = {
    # zsh.enable = true;
    # bash.enable = true;
    # LD.enable = true;
  };

  # boot.kernelModules = ["kvm-amd" "kvm-intel"];

  services.clamav = {
    daemon.enable = true;
    updater.enable = true;
    updater.interval = "weekly";
  };

  environment.shellAliases = {
    lsnc = "lsd --color=never";
    la = "lsd -a";
    ll = "lsd -lh";
    l = "lsd -alh";
  };

  # # Bootloader.
  # boot.loader.timeout = 3;
  # boot.loader.systemd-boot.editor = false;
  # boot.loader.systemd-boot.configurationLimit = 50;
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = hostname; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # # Enable networking
  # networking.networkmanager.enable = true;

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
      flake = "/home/${username}/nix-config";
    };
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # hardware.bluetooth.enable = true; # enables support for Bluetooth
  # hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  # services.blueman.enable = true;

  # # Enable CUPS to print documents.
  # services.printing.enable = true;
  # services.printing.drivers = with pkgs; [gutenprint hplip splix];
  # services.printing.webInterface = false;

  # # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;
  # services.libinput.touchpad.disableWhileTyping = true;

  users.defaultUserShell = pkgs.zsh;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
    enableSSHSupport = true;
  };

  environment = {
    enableAllTerminfo = true;

    # Add ~/.local/bin to PATH
    localBinInPath = true;

    pathsToLink = [
      "/share/bash-completion"
      "/share/zsh"
    ];

    shells = [pkgs.zsh];

    # List packages installed in system profile. To search, run:
    # $ nix search wget
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
      # options = "-d";
      # persistent = true;
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

  sops = {
    defaultSopsFile = "${inputs.mysecrets}/secrets/nix.yaml";
    age.sshKeyPaths = ["/home/${username}/.ssh/${hostname}"];
    secrets."passwords/${username}" = {
      neededForUsers = true;
    };
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = stateVersion; # Did you read the comment?
}
