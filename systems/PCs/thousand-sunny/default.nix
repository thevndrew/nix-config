{
  mylib,
  systemInfo,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    # Setup WOL systemd service
    (import (mylib.relativeToRoot "hosts/common/systemd/wol.nix") {
      wolCommand = "ethtool -s eno1 wol g";
    })
  ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
    };

    kernelParams = ["xhci_hcd.quirks=270336"];
    #kernel.sysctl = { "xhci_hcd.quirks" = 270336; };
    supportedFilesystems = ["zfs"];
    zfs = {
      forceImportRoot = false;
      extraPools = [
        "tank00"
        "tank01"
        "tank02"
        "tank03"
      ];
    };
  };

  services.zfs.autoScrub = {
    enable = true;
    interval = "monthly";
  };

  fileSystems."/mnt/storage" = {
    fsType = "fuse.mergerfs";
    device = "/mnt/tank00/storage:/mnt/tank01/storage:/mnt/tank02/storage:/mnt/tank03/storage";
    options = [
      "cache.files=off"
      "dropcacheonclose=true"
      "category.create=mfs"
      "moveonenospc=true"
      "minfreespace=250G"
      "fsname=mergerfs"
    ];
  };

  hardware.sensor.hddtemp = {
    enable = true;
    drives = [
      "/dev/disk/by-id/ata-ST18000NM000J-2TV103_ZR5CR6Z2"
      "/dev/disk/by-id/ata-ST18000NM000J-2TV103_ZR5DT8NB"
      "/dev/disk/by-id/ata-ST20000NM007D-3DJ103_ZVT5F6LH"
      "/dev/disk/by-id/ata-ST20000NM007D-3DJ103_ZVT5HSG7"
      "/dev/disk/by-id/ata-ST20000NM007D-3DJ103_ZVT5JS1S"
      "/dev/disk/by-id/ata-ST20000NM007D-3DJ103_ZVT5KD96"
    ];
    unit = "C";
  };

  powerManagement = {
    cpuFreqGovernor = "powersave";
    powertop.enable = true;
    cpufreq.min = 800000; # 800 Mhz
    cpufreq.max = 3400000; # 3.5 Ghz
  };

  users.groups.storage = {gid = 1000;};
  users.users.${systemInfo.user}.extraGroups = ["wheel" "podman" "storage" "input"];

  networking = {
    hostName = systemInfo.hostname;
    hostId = "4a219e7f";
  };

  system.stateVersion = "23.11"; # Did you read the comment?
}
