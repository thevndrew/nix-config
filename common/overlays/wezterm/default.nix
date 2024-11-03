importName: inputs: (final: prev: let
  pkgs = import inputs.nixpkgsNV {inherit (prev) system;};
  tmux = pkgs.callPackage ../tmux/package.nix {};
  zdotdir = pkgs.callPackage ../zdot {};
  wrapZSH = false;
in {
  ${importName} = pkgs.callPackage ./wez {inherit tmux zdotdir wrapZSH;};
})
