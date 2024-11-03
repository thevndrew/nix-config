{
  mylib,
  pkgs,
  systemInfo,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    # Setup WOL systemd service
    (import (mylib.relativeToRoot "hosts/common/systemd/wol.nix") {
      wolCommand = "ethtool -s enp1s0 wol g && ethtool -s enp2s0 wol g";
    })
  ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };
  };

  users.users.${systemInfo.user}.extraGroups = ["wheel" "podman"];
  #extraGroups = [ "wheel" "docker" ];

  networking = {
    hostName = systemInfo.hostname;
  };

  systemd.services."qbittorrent_restart" = {
    enable = true;
    description = "qbittorrent automatic restart";
    path = [pkgs.docker-client];
    unitConfig = {
      Type = "oneshot";
    };
    serviceConfig = {
      ExecStart = "/bin/sh -c '${systemInfo.home}/repos/services/qbittorrent/restart.sh'";
      User = systemInfo.user;
      Group = "users";
    };
    startAt = "hourly";
    wantedBy = ["multi-user.target"];
  };

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?
}
