{inputs, ...}: let
  inherit (inputs.nixpkgs) lib;
  my-utils = import ./util {inherit inputs lib;};
in {
  inherit my-utils;

  hub = {
    HM ? true,
    nixos ? true,
    overlays ? true,
    packages ? true,
    disko ? true,
    flakeMods ? true,
    templates ? true,
    userdata ? true,
    ...
  }: let
    vndrew-nvim = inputs.vndrew-nvim;

    nixosMods = import ./modules {
      inherit inputs my-utils;
      homeManager = false;
    };

    homeMods = import ./modules {
      inherit inputs my-utils;
      homeManager = true;
    };

    overs = import ./overlays {inherit inputs my-utils;};

    mypkgs = system: (import ./pkgs {inherit inputs system my-utils;});

    usrdta = pkgs: import ./userdata {inherit inputs my-utils lib;} pkgs;

    FM = import ./flakeModules {inherit inputs my-utils;};
  in {
    home-modules = lib.optionalAttrs HM homeMods;
    system-modules = lib.optionalAttrs nixos nixosMods;
    overlaySet = lib.optionalAttrs overlays overs;
    packages =
      if packages
      then mypkgs
      else (_: {});
    diskoCFG = lib.optionalAttrs disko (import ./disko);
    flakeModules = lib.optionalAttrs flakeMods FM;
    templates = lib.optionalAttrs templates (import ./templates inputs);
    userdata =
      if userdata
      then usrdta
      else (_: {});
  };
}
