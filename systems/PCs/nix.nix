{
  lib,
  config,
  pkgs,
  inputs,
  isDesktop,
  isWSL,
  user,
  hostname,
  ...
}: let
in {
  #nixpkgs.overlays = import ../../lib/overlays.nix ++ [
  #  (import ./vim.nix { inherit inputs; })
  #];
}
