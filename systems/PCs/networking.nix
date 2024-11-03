{
  config,
  lib,
  ...
}: let
  cfg = config.my-networking;
in {
  options = {
    my-networking.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = "enable networking related configuration";
    };
  };

  config = lib.mkIf cfg.enable {
    networking = {
      # enableIPv6  = false;
      firewall = {
        # enable the firewall
        enable = true;

        # always allow traffic from your Tailscale network
        trustedInterfaces = ["tailscale0"];

        # allow you to SSH in over the public internet
        allowedTCPPorts = [
          22
          2222
        ];
      };
      nameservers = [
        "100.100.100.100"
        "9.9.9.9"
      ];
      search = [
        "ainu-kanyu.ts.net"
      ];
    };
  };
}
