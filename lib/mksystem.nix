# This function creates a NixOS system based on our VM setup for a
# particular architecture.
{ nixpkgs, nixpkgs-unstable, overlays, inputs }:

name:
{
  system,
  user,
  wsl ? false,
  desktop ? false
}:

let
  # True if this is a WSL system.
  isWSL = wsl;

  # The config files for this system.
  machineConfig = ../hosts/${name}/configuration.nix;
  userOSConfig = ../users/${user}/nixos${if desktop then "desktop" else ""}.nix;
  userHMConfig = ../users/${user}/home-manager.nix;

  systemFunc = nixpkgs.lib.nixosSystem;
  home-manager = inputs.home-manager.nixosModules;

  pkgs-unstable = import nixpkgs-unstable {
    inherit system;
    config = {
      allowUnfree = true;
    };
  };

in systemFunc rec {
  inherit system;

  specialArgs = { inherit inputs; inherit system; inherit pkgs-unstable; };

  modules = [
    # Apply our overlays. Overlays are keyed by system type so we have
    # to go through and apply our system type. We do this first so
    # the overlays are available globally.
    { nixpkgs.overlays = overlays; }

    # Bring in WSL if this is a WSL build
    (if isWSL then inputs.nixos-wsl.nixosModules.wsl else {})

    machineConfig
    userOSConfig
    home-manager.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${user} = import userHMConfig {
        isWSL = isWSL;
        isDesktop = desktop;
        inputs = inputs;
      };
    }

    # We expose some extra arguments so that our modules can parameterize
    # better based on these values.
    {
      config._module.args = {
        currentSystem = system;
        currentSystemName = name;
        currentSystemUser = user;
        isWSL = isWSL;
        isDesktop = desktop;
        inputs = inputs;
      };
    }
  ];
}

