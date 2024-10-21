{inputs, ...}: let
  utils = import ./util inputs;
  vndrew-nvim = inputs.vndrew-nvim;
in {
  inherit vndrew-nvim utils;
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
    inherit (inputs.nixpkgs) lib;
    nixosMods =
      (import ./modules {
        inherit inputs utils;
        homeManager = false;
      })
      // {vndrew-nvim = vndrew-nvim.nixosModules.default;};
    homeMods =
      (import ./modules {
        inherit inputs utils;
        homeManager = true;
      })
      // {vndrew-nvim = vndrew-nvim.homeModule;};
    overs = (import ./overlays {inherit inputs utils;}) // {vndrew-nvim = vndrew-nvim.overlays.default;};
    mypkgs = system: (import ./pkgs {inherit inputs system utils;}) // vndrew-nvim.packages.${system};
    usrdta = pkgs: import ./userdata {inherit inputs utils;} pkgs;
    FM = import ./flakeModules {inherit inputs utils;};
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
