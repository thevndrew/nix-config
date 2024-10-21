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
{
  inputs,
  birdeeutils,
  ...
}: let
  overlaySetPre = {
    # this is how you would add another overlay file
    # for if your customBuildsOverlay gets too long
    # the name here will be the name used when importing items from it in your flake.
    # i.e. these items will be accessed as pkgs.nixCatsBuilds.thenameofthepackage

    # except this one which outputs wherever it needs to.
    pinnedVersions = import ./pinnedVersions.nix;

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
    };
in
  overlaySet
