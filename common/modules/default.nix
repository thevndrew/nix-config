{
  inputs,
  homeManager ? false,
  utils,
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
  args = {inherit inputs moduleNamespace homeManager utils;};
in {
  alacritty = import ./alacritty args;
  cockpit = import ./cockpit args;
  firefox = import (homeOnly ./firefox) args;
  gui-home = import (homeOnly ./gui/home) args;
  gui-system = import (systemOnly ./gui/system) args;
  LD = import (systemOnly ./LD) args;
  samba = import ./samba args;
  shell = import ./shell args;
  thunar = import (homeOnly ./thunar) args;
  tmux = import ./tmux args;
  wol = import (systemOnly ./wol) args;
  wsl = import ./wsl args;
}
