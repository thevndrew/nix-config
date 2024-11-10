{
  inputs,
  homeManager ? false,
  my-utils,
  ...
}: let
  homeOnly = path: (
    if homeManager
    then path
    else builtins.throw "no system module with that name"
  );
  systemOnly = path: (
    if homeManager
    then builtins.throw "no home-manager module with that name"
    else path
  );
  moduleNamespace = "vndrewMods";
  args = {inherit inputs moduleNamespace homeManager my-utils;};
in {
  gui-home = import (homeOnly ./gui/home) args;
  gui-system = import (systemOnly ./gui/system) args;

  cockpit = import (systemOnly ./cockpit) args;
  LD = import (systemOnly ./LD) args;
  networking = import (systemOnly ./networking) args;
  samba = import (systemOnly ./samba) args;
  virtualisation = import (systemOnly ./virtualisation) args;
  wol = import (systemOnly ./wol) args;
  wsl = import (systemOnly ./wsl) args;

  terminals = import (homeOnly ./terminals) args;
  vndrew-nvim = homeOnly inputs.vndrew-nvim.homeModule;
  # vndrew-nvim = systemOnly inputs.vndrew-nvim.nixosModules.default;

  alacritty = import ./alacritty args;
  firefox = import (homeOnly ./firefox) args;
  shell = import ./shell args;
  thunar = import (homeOnly ./thunar) args;
  tmux = import ./tmux args;
}
