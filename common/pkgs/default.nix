{
  inputs,
  system,
  ...
}: let
  pkgs = import inputs.nixpkgs-unstable {
    inherit system;
  };

  args = {inherit pkgs;};
in {
  clone_repos = import ./clone_repos args;
  sops_secrets_key = import ./sops_secrets_key args;
  update_input = import ./update_input args;
  vndrew-nvim = inputs.vndrew-nvim.packages.${system};
}
