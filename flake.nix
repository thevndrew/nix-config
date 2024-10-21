{
  description = ''
    Andrew's system. common/default.nix handles passing modules
    and config files to home and the system.

    flake.nix contains only inputs,
    the outputs function are in ./default.nix

    Shoutout to BirdeeHub, my config is based on heavly referencing
    their config at https://github.com/BirdeeHub/birdeeSystems/
  '';

  # TODO: setup personal binary cache
  nixConfig = {
    extra-substituters = [
    ];
    extra-trusted-public-keys = [
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nur.url = "github:nix-community/NUR";

    home-manager = {
      url = "github:nix-community/home-manager?ref=release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Build a custom WSL installer
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    alacritty-theme.url = "github:alexghr/alacritty-theme.nix";
    devenv.url = "github:cachix/devenv";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils.url = "github:numtide/flake-utils";
    manix.inputs.flake-utils.follows = "flake-utils";
    manix.inputs.nixpkgs.follows = "nixpkgs-unstable";
    manix.url = "github:nix-community/manix";
    minesweeper.inputs.nixpkgs.follows = "nixpkgs-unstable";
    minesweeper.url = "github:BirdeeHub/minesweeper";
    nix-appimage.url = "github:ralismark/nix-appimage";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixToLua.url = "github:BirdeeHub/nixtoLua";
    nsearch.inputs.nixpkgs.follows = "nixpkgs";
    nsearch.url = "github:niksingh710/nsearch";
    templ.url = "github:a-h/templ";
    zig.url = "github:mitchellh/zig-overlay";

    # Window Manager/Desktop Environment stuff
    ags.url = "github:Aylur/ags";
    anyrun.url = "github:anyrun-org/anyrun";
    anyrun.inputs.nixpkgs.follows = "nixpkgs";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    wezterm.url = "github:wez/wezterm?dir=nix";
    zen-browser.url = "github:MarceColl/zen-browser-flake";

    # Tool to run unpatched binaries
    nix-alien.url = "github:thiagokokada/nix-alien";

    # Weekly Updated nix-index database
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Non-flake inputs
    nnn = {
      url = "github:jarun/nnn";
      flake = false;
    };
    zsh-completions = {
      url = "github:zsh-users/zsh-completions";
      flake = false;
    };
    fzf-tab = {
      url = "github:Aloxaf/fzf-tab";
      flake = false;
    };

    # My package repo(s) and neovim config
    nixpkgs-vndrew = {
      url = "git+ssh://git@github.com/thevndrew/nix-packages.git";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nixpkgs-secret = {
      url = "git+ssh://git@github.com/thevndrew/nix-secret-pkgs.git";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    vndrew-nvim = {
      url = "git+ssh://git@github.com/thevndrew/vndrew.nvim";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # sops and sops encrypted secrets
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Use ssh protocol to authenticate via ssh-agent/ssh-key, and shallow clone
    mysecrets = {
      url = "git+ssh://git@github.com/thevndrew/nix-secrets.git?shallow=1";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    ...
  } @ inputs: let
    system = "x86_64-linux";

    overlays = [
      inputs.nur.overlay
      inputs.zig.overlays.default
    ];

    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };

    other-pkgs = {
      nix-alien = inputs.nix-alien.packages.${pkgs.system};

      unstable = import inputs.nixpkgs-unstable {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };

      vndrew = inputs.nixpkgs-vndrew.packages.${pkgs.system};
      secret = inputs.nixpkgs-secret.packages.${pkgs.system};
    };

    mylib = import ./lib/mylib.nix {inherit (nixpkgs) lib;};

    mkSystem = import ./lib/mksystem.nix {
      inherit nixpkgs overlays inputs pkgs other-pkgs mylib;
    };

    homeManagerSetup = {
      hostname,
      user,
    }: (
      let
        systemInfo = {
          home = "/home/${user}";
          inherit hostname;
          inherit user;
          arch = system;
        };

        moduleArgs = {
          isDesktop = false;
          isWSL = true;
          isStandalone = true;
          sopsKeys = mylib.getSopsKeys user;
          inherit inputs;
          inherit mylib;
          inherit other-pkgs;
          inherit systemInfo;
        };
      in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = moduleArgs;
          modules = [
            inputs.nix-index-database.hmModules.nix-index
            inputs.sops-nix.homeManagerModules.sops
            inputs.vndrew-nvim.homeModule
            ./users/${user}/home
          ];
        }
    );
  in {
    nixosConfigurations = {
      going-merry = mkSystem "going-merry" {
        inherit system;
        user = "andrew";
      };

      thousand-sunny = mkSystem "thousand-sunny" {
        inherit system;
        user = "andrew";
        desktop = true;
      };

      polar-tang = mkSystem "polar-tang" {
        inherit system;
        user = "andrew";
        wsl = true;
      };
    };

    formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;

    homeConfigurations = {
      andrew = homeManagerSetup {
        hostname = "polar-tang";
        user = "andrew";
      };
    };

    devShells.${system} = {
      default = pkgs.mkShell {
        nativeBuildInputs = with other-pkgs.unstable; [
          alejandra
          deadnix
          just
          nixd
          statix
        ];
      };
    };
  };
}
