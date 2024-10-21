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
  LD = import (systemOnly ./LD) args;
  firefox = import (homeOnly ./firefox) args;
  thunar = import (homeOnly ./thunar) args;
  ranger = import ./ranger args;
  alacritty = import ./alacritty args;
  tmux = import ./tmux args;
  shell = import ./shell args;
}
