{pkgs, ...}:
pkgs.writeShellApplication {
  name = "update_input";
  runtimeInputs = with pkgs; [fzf jq];
  text = ''
    input=$(nix flake metadata --json                \
         | jq -r ".locks.nodes.root.inputs | keys[]" \
         | fzf)
    nix flake lock --update-input "$input"
  '';
}
