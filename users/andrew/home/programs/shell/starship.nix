{ other-pkgs, ... }:
let
  unstable = other-pkgs.unstable;
in
{
  programs.starship = import ../integration_settings.nix // {
    enable = true;
    package = unstable.starship;
    settings = {
      palette = "gruvbox_dark";

      palettes.gruvbox_dark = {
        color_fg0 = "#fbf1c7";
        color_bg1 = "#3c3836";
        color_bg3 = "#665c54";
        color_blue = "#458588";
        color_aqua = "#689d6a";
        color_green = "#98971a";
        color_orange = "#d65d0e";
        color_purple = "#b16286";
        color_red = "#cc241d";
        color_yellow = "#d79921";
      };
    };
  };
}
