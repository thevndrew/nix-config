# Arion works with Docker, but for NixOS-based containers, you need Podman
# since NixOS 21.05.
{moduleNamespace, ...}: {
  config,
  lib,
  ...
}: let
  cfg = config.${moduleNamespace}.virtualisation;
in {
  _file = ./default.nix;
  options = {
    ${moduleNamespace}.virtualisation = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        example = false;
        description = "enable networking related configuration";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation = {
      libvirtd = {
        enable = true;
      };

      containers = {
        enable = true;
        containersConf = {
          settings = {
            network = {
              # Change dns port to allow running
              # so it doesn't conflict with
              # pihole container that I use for DNS
              dns_bind_port = 54;
            };
            engine = {
              network_cmd_options = [
                "mtu=1280"
                # "outbound_addr=tailscale0"
                # "outbound_addr6=tailscale0"
              ];
            };
          };
        };
      };

      oci-containers.backend = "podman";

      docker = {
        enable = false;
      };

      podman = {
        enable = true;
        autoPrune = {
          enable = true;
          dates = "weekly";
        };
        dockerSocket.enable = true;
        defaultNetwork.settings.dns_enable = true;
        # extraPackages = [ pkgs.zfs ]; # Required if the host is running ZFS
      };
    };
  };
}
