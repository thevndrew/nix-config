/*
This file imports overlays defined in the following format.
*/
# Example overlay:
/*
importName: inputs: let
  overlay = self: super: {
    ${importName} = {
      # define your overlay derivations here
    };
  };
in
overlay
*/
{inputs, ...}: let
  overlaySetPre = {
    dep-tree = import ./dep-tree;
    nops = import ./nops;
    # tmux = import ./tmux;
    #
    # # work in progress?
    # alakazam = import ./alakitty;
    # wezterm = import ./wezterm;
    # foot = import ./foot;
  };
  overlaySetMapped = builtins.mapAttrs (name: value: (value name inputs)) overlaySetPre;
  overlaySet =
    overlaySetMapped
    // {
      nur = inputs.nur.overlay;
      minesweeper = inputs.minesweeper.overlays.default;
      vndrew-nvim = inputs.vndrew-nvim.overlays.default;
    };
in
  overlaySet
