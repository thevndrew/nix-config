{other-pkgs, ...}: let
  inherit (other-pkgs) unstable;
in {
  programs.zoxide =
    import ./settings/shell_integrations.nix
    // {
      enable = true;
      package = unstable.zoxide;
      options = ["--cmd cd"];
    };
}
