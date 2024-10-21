{
  self,
  nixpkgs,
  home-manager,
  disko,
  nix-appimage,
  flake-parts,
  ...
} @ inputs: let
  # NOTE: setup
  flake-path = "/home/andrew/nix-config";
  stateVersion = "23.11";
  common = import ./common {inherit inputs flake-path;};
  inherit (common) vndrew-nvim utils;
  my_common_hub = common.hub {};
  inherit (my_common_hub) system-modules home-modules overlaySet flakeModules diskoCFG templates userdata;
  packages_func = my_common_hub.packages;
  overlayList = builtins.attrValues overlaySet;
  # factor out declaring home manager as a module for configs that do that
  HMasModule = {
    users,
    monitorCFG ? null,
    username,
    hmCFGmodMAIN,
  }: {
    pkgs,
    lib,
    ...
  }: {
    nixpkgs.overlays = overlayList;
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.vndrew = hmCFGmodMAIN; # import ./homes/vndrew.nix;
    home-manager.backupFileExtension = "hm-bkp";
    home-manager.verbose = true;
    home-manager.extraSpecialArgs = {
      my_pkgs = packages_func pkgs.system;
      inherit
        stateVersion
        self
        inputs
        home-modules
        flake-path
        username # username = "vndrew";
        users
        monitorCFG
        utils
        ;
    }; # monitorCFG = ./homes/monitors_by_hostname/<hostname>;
    services.displayManager.defaultSession = lib.mkDefault "none+fake";
  };
in
  # NOTE: flake parts definitions
  # https://flake.parts/options/flake-parts
  # https://devenv.sh/reference/options
  flake-parts.lib.mkFlake {inherit inputs;} {
    systems = nixpkgs.lib.platforms.all;
    imports = [
      # inputs.flake-parts.flakeModules.easyOverlay
      inputs.devenv.flakeModule
      flakeModules.nixosCFGperSystem
      flakeModules.homeCFGperSystem
      flakeModules.appImagePerSystem

      # e.g. treefmt-nix.flakeModule
    ];
    flake = {
      diskoConfigurations = {
        sda_swap = diskoCFG.PCs.sda_swap;
        sdb_swap = diskoCFG.PCs.sdb_swap;
        dustbook = diskoCFG.PCs.sda_swap;
        nestOS = diskoCFG.PCs.sda_swap;
        "vmware-vm" = diskoCFG.VMs.vmware_bios;
        "vndrew@nestOS" = diskoCFG.PCs.sda_swap;
        "vndrew@dustbook" = diskoCFG.PCs.sda_swap;
      };
      overlays = overlaySet // vndrew-nvim.overlays // {};
      nixosModules = system-modules;
      homeModules = home-modules;
      inherit vndrew-nvim flakeModules templates utils;
    };
    perSystem = {
      config,
      self',
      inputs',
      lib,
      pkgs,
      system,
      # final, # Only with easyOverlay imported
      ...
    }: {
      _module.args.pkgs = import inputs.nixpkgs-unstable {
        inherit system;
        overlays = overlayList;
        config = {
          allowUnfree = true;
        };
      };

      # overlayAttrs = { outname = config.packages.packagename; }; # Only with easyOverlay imported

      packages =
        (packages_func system)
        // {
          footy = pkgs.foot.override {
            wrapZSH = true;
            extraPATH = [
            ];
          };
          wezshterm = pkgs.wezterm.override {
            wrapZSH = true;
            extraPATH = [
            ];
          };
          alakitty = pkgs.alakazam.override {
            wrapZSH = true;
            extraPATH = [
            ];
          };
          inherit (pkgs) dep-tree minesweeper nops manix tmux alakazam wezterm foot;
        };

      app-images =
        vndrew-nvim.app-images.${system}
        // (
          let
            bundle = nix-appimage.bundlers.${system}.default;
          in {
            minesweeper = bundle pkgs.minesweeper;
          }
        );

      # NOTE: outputs to legacyPackages.${system}.homeConfigurations.<name>
      homeConfigurations = let
        users = userdata pkgs;
      in {
        "vndrew@dustbook" = home-manager.lib.homeManagerConfiguration {
          extraSpecialArgs = {
            username = "vndrew";
            monitorCFG = ./homes/monitors_by_hostname/dustbook;
            my_pkgs = packages_func system;
            inherit
              stateVersion
              self
              system
              inputs
              users
              home-modules
              flake-path
              utils
              ;
          };
          inherit pkgs;
          modules = [
            ./homes/vndrew.nix
            (
              {pkgs, ...}: {
                nix.package = pkgs.nix;
              }
            )
          ];
        };
        "vndrew@nestOS" = home-manager.lib.homeManagerConfiguration {
          extraSpecialArgs = {
            username = "vndrew";
            monitorCFG = ./homes/monitors_by_hostname/nestOS;
            my_pkgs = packages_func system;
            inherit
              stateVersion
              self
              system
              inputs
              users
              home-modules
              flake-path
              utils
              ;
          };
          inherit pkgs;
          modules = [
            ./homes/main
            (
              {pkgs, ...}: {
                nix.package = pkgs.nix;
              }
            )
          ];
        };
      };

      # NOTE: outputs to legacyPackages.${system}.nixosConfigurations.<name>
      nixosConfigurations = let
        users = userdata pkgs;
      in {
        "vndrew@nestOS" = nixpkgs.lib.nixosSystem {
          specialArgs = {
            hostname = "nestOS";
            my_pkgs = packages_func system;
            inherit
              stateVersion
              self
              inputs
              users
              system-modules
              flake-path
              utils
              ;
          };
          inherit system;
          modules = [
            home-manager.nixosModules.home-manager
            disko.nixosModules.disko
            diskoCFG.PCs.sda_swap
            ./systems/PCs/aSUS
            (HMasModule {
              monitorCFG = ./homes/monitors_by_hostname/nestOS;
              username = "vndrew";
              inherit users;
              hmCFGmodMAIN = import ./homes/main;
            })
          ];
        };
        "vndrew@dustbook" = nixpkgs.lib.nixosSystem {
          specialArgs = {
            hostname = "dustbook";
            my_pkgs = packages_func system;
            inherit
              stateVersion
              users
              self
              inputs
              system-modules
              flake-path
              utils
              ;
          };
          inherit system;
          modules = [
            home-manager.nixosModules.home-manager
            disko.nixosModules.disko
            diskoCFG.PCs.sda_swap
            ./systems/PCs/dustbook
            (HMasModule {
              monitorCFG = ./homes/monitors_by_hostname/dustbook;
              username = "vndrew";
              inherit users;
              hmCFGmodMAIN = import ./homes/vndrew.nix;
            })
          ];
        };
        "nestOS" = nixpkgs.lib.nixosSystem {
          specialArgs = {
            hostname = "nestOS";
            my_pkgs = packages_func system;
            inherit
              stateVersion
              self
              inputs
              users
              system-modules
              flake-path
              utils
              ;
          };
          inherit system;
          modules = [
            {nixpkgs.overlays = overlayList;}
            disko.nixosModules.disko
            diskoCFG.PCs.sda_swap
            ./systems/PCs/aSUS
          ];
        };
        "dustbook" = nixpkgs.lib.nixosSystem {
          specialArgs = {
            hostname = "dustbook";
            my_pkgs = packages_func system;
            inherit
              stateVersion
              self
              inputs
              users
              system-modules
              flake-path
              utils
              ;
          };
          inherit system;
          modules = [
            {nixpkgs.overlays = overlayList;}
            disko.nixosModules.disko
            diskoCFG.PCs.sda_swap
            ./systems/PCs/dustbook
          ];
        };
        "vmware-vm" = nixpkgs.lib.nixosSystem {
          specialArgs = {
            hostname = "virtbird";
            my_pkgs = packages_func system;
            inherit
              stateVersion
              self
              inputs
              users
              system-modules
              flake-path
              utils
              ;
          };
          inherit system;
          modules = [
            home-manager.nixosModules.home-manager
            disko.nixosModules.disko
            diskoCFG.VMs.vmware_bios
            ./systems/VMs/vmware
            (HMasModule {
              username = "vndrew";
              inherit users;
              hmCFGmodMAIN = import ./homes/vndrew.nix;
            })
          ];
        };
        "my-qemu-vm" = nixpkgs.lib.nixosSystem {
          specialArgs = {
            hostname = "virtbird";
            my_pkgs = packages_func system;
            inherit
              stateVersion
              self
              inputs
              users
              system-modules
              flake-path
              utils
              ;
          };
          inherit system;
          modules = [
            home-manager.nixosModules.home-manager
            ./systems/VMs/qemu
            (HMasModule {
              username = "vndrew";
              inherit users;
              hmCFGmodMAIN = import ./homes/vndrew.nix;
            })
          ];
        };
        "installer_mine" = inputs.nixpkgs-unstable.lib.nixosSystem {
          specialArgs = {
            hostname = "installer_mine";
            is_minimal = true;
            use_alacritty = true;
            my_pkgs = packages_func system;
            inherit
              stateVersion
              self
              inputs
              users
              system-modules
              flake-path
              utils
              ;
          };
          inherit system;
          modules = [
            {nixpkgs.overlays = overlayList;}
            ./systems/installers/installer_mine
            # home-manager.nixosModules.home-manager
            # (HMasModule {
            #   username = "vndrew";
            #   inherit users;
            #   hmCFGmodMAIN = import ./homes/vndrew.nix;
            # })
          ];
        };
        "installer" = inputs.nixpkgs-unstable.lib.nixosSystem {
          specialArgs = {
            my_pkgs = packages_func system;
            inherit self inputs system-modules utils;
          };
          inherit system;
          modules = [
            {nixpkgs.overlays = overlayList;}
            ./systems/installers/installer
          ];
        };
      };
    };
  }
