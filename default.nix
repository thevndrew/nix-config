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

  inherit (common) my-utils;

  my_common_hub = common.hub {};

  inherit (my_common_hub) system-modules home-modules overlaySet flakeModules diskoCFG templates userdata;

  packages_func = my_common_hub.packages;

  overlayList =
    (builtins.attrValues overlaySet)
    ++ [
      (final: prev: {
        # Add other packages under namespaces
        nix-alien = inputs.nix-alien.packages.${final.system};

        unstable = import inputs.nixpkgs-unstable {
          inherit (final) system;
          config = {
            allowUnfree = true;
          };
        };

        vndrew = inputs.nixpkgs-vndrew.packages.${final.system};
        secret = inputs.nixpkgs-secret.packages.${final.system};
        my_pkgs = packages_func final.system;
      })

      inputs.nur.overlay
      inputs.zig.overlays.default
    ];

  # factor out declaring home manager as a module for configs that do that
  HMasModule = {
    users,
    monitorCFG ? null,
    username,
    hmCFGmodMAIN,
    isWSL ? false,
    isDesktop ? false,
    isStandalone ? false,
    hostname,
  }: {pkgs, ...}: {
    nixpkgs.overlays = overlayList;
    home-manager = {
      backupFileExtension = "hm-bkp";
      extraSpecialArgs = {
        inherit
          stateVersion
          self
          inputs
          home-modules
          flake-path
          username
          users
          monitorCFG
          my-utils
          isWSL
          isDesktop
          isStandalone
          hostname
          ;
      };
      sharedModules = [
        inputs.ags.homeManagerModules.default
        inputs.anyrun.homeManagerModules.default
        inputs.sops-nix.homeManagerModules.sops
        inputs.nix-index-database.hmModules.nix-index
      ];
      useGlobalPkgs = true;
      useUserPackages = true;
      users.andrew = hmCFGmodMAIN;
      verbose = true;
    };
  };
in
  # NOTE: flake parts definitions
  # https://flake.parts/options/flake-parts
  # https://devenv.sh/reference/options
  flake-parts.lib.mkFlake {inherit inputs;} {
    systems = nixpkgs.lib.platforms.all;
    imports = [
      # inputs.flake-parts.flakeModules.easyOverlay
      # inputs.devenv.flakeModule
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
      overlays = overlaySet;
      nixosModules = system-modules;
      homeModules = home-modules;
      inherit flakeModules templates my-utils;
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
      # _module.args.pkgs = import inputs.nixpkgs-unstable {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = overlayList;
        config = {
          allowUnfree = true;
        };
      };

      formatter = nixpkgs.legacyPackages.${system}.alejandra;

      packages =
        (packages_func system)
        // {
          # footy = pkgs.foot.override {
          #   wrapZSH = true;
          #   extraPATH = [
          #   ];
          # };
          # wezshterm = pkgs.wezterm.override {
          #   wrapZSH = true;
          #   extraPATH = [
          #   ];
          # };
          # alakitty = pkgs.alakazam.override {
          #   wrapZSH = true;
          #   extraPATH = [
          #   ];
          # };
          inherit (pkgs) dep-tree; # minesweeper nops manix tmux alakazam wezterm foot;
        };

      app-images = let
        bundle = nix-appimage.bundlers.${system}.default;
      in {
        minesweeper = bundle pkgs.minesweeper;
      };

      # NOTE: outputs to legacyPackages.${system}.homeConfigurations.<name>
      homeConfigurations = let
        users = userdata {inherit pkgs;};
      in {
        "andrew@dustbook" = home-manager.lib.homeManagerConfiguration {
          extraSpecialArgs = {
            username = "andrew";
            my_pkgs = packages_func system;
            inherit
              stateVersion
              self
              system
              inputs
              users
              home-modules
              flake-path
              my-utils
              ;
          };
          inherit pkgs;
          modules = [
            ./homes/andrew.nix
            (
              {pkgs, ...}: {
                nix.package = pkgs.nix;
              }
            )
          ];
        };
        "andrew@nestOS" = home-manager.lib.homeManagerConfiguration {
          extraSpecialArgs = {
            username = "andrew";
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
              my-utils
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

      devShells = {
        default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            alejandra
            deadnix
            just
            nixd
            statix
          ];
        };
      };

      # NOTE: outputs to legacyPackages.${system}.nixosConfigurations.<name>
      nixosConfigurations = let
        users = userdata {inherit pkgs;};
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
              my-utils
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
              username = "andrew";
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
              my-utils
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
              my-utils
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
              my-utils
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
              my-utils
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
              my-utils
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
              my-utils
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
            inherit self inputs system-modules my-utils;
          };
          inherit system;
          modules = [
            {nixpkgs.overlays = overlayList;}
            ./systems/installers/installer
          ];
        };

        going-merry = nixpkgs.lib.nixosSystem {
          specialArgs = {
            hostname = "going-merry";
            username = "andrew";
            inherit
              stateVersion
              users
              self
              inputs
              system-modules
              flake-path
              my-utils
              ;
          };
          inherit system;
          modules = [
            inputs.sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            ./systems/PCs/going-merry
            (HMasModule {
              inherit users;
              hostname = "going-merry";
              username = "andrew";
              hmCFGmodMAIN = import ./homes/andrew.nix;
            })
          ];
        };

        thousand-sunny = nixpkgs.lib.nixosSystem {
          specialArgs = {
            hostname = "thousand-sunny";
            username = "andrew";
            inherit
              stateVersion
              users
              self
              inputs
              system-modules
              flake-path
              my-utils
              ;
          };
          inherit system;
          modules = [
            inputs.sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            ./systems/PCs/thousand-sunny
            (HMasModule {
              inherit users;
              hostname = "thousand-sunny";
              username = "andrew";
              isDesktop = true;
              hmCFGmodMAIN = import ./homes/andrew.nix;
            })
          ];
        };

        polar-tang = nixpkgs.lib.nixosSystem {
          specialArgs = {
            hostname = "polar-tang";
            username = "andrew";
            inherit
              stateVersion
              users
              self
              inputs
              system-modules
              flake-path
              my-utils
              ;
          };
          inherit system;
          modules = [
            inputs.sops-nix.nixosModules.sops
            inputs.nixos-wsl.nixosModules.default
            home-manager.nixosModules.home-manager
            ./systems/PCs/polar-tang
            (HMasModule {
              inherit users;
              hostname = "polar-tang";
              username = "andrew";
              isWSL = true;
              hmCFGmodMAIN = import ./homes/andrew.nix;
            })
          ];
        };
      };
    };
  }
