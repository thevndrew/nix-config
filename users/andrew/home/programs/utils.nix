{other-pkgs, ...}: let
  unstable = other-pkgs.unstable;
in {
  programs = {
    ripgrep = {
      enable = true;
      package = unstable.ripgrep;
    };

    broot =
      import ./integration_settings.nix
      // {
        enable = true;
        package = unstable.broot;
        settings = {
          modal = true;
        };
      };

    bat = {
      enable = true;
      package = unstable.bat;
      extraPackages = with unstable.bat-extras; [
        batdiff
        batgrep
        batman
        batpipe
        batwatch
        prettybat
      ];
    };
  };
}
