{pkgs, ...}: let
  get_key = pkgs.writeShellApplication {
    name = "get_sops_key";
    runtimeInputs = with pkgs; [ssh-to-age ripgrep fzf];
    text = ''
      set +o errexit

      key=$(find ~/.ssh -type f -printf "%f\n" | rg -v '^config$|^known_hosts$|.pub$' | fzf)
      ssh-to-age -private-key -i "$HOME/.ssh/$key" > "/tmp/$key".txt
      SOPS_AGE_KEY_FILE="/tmp/$key".txt
      export SOPS_AGE_KEY_FILE

      set +o nounset
      set +o pipefail
    '';
  };

  remove_key = pkgs.writeShellApplication {
    name = "remove_sops_key";
    text = ''
      set +o errexit
      rm -v "$SOPS_AGE_KEY_FILE"
      unset SOPS_AGE_KEY_FILE
      set +o nounset
      set +o pipefail
    '';
  };
in
  pkgs.buildEnv {
    name = "sops_secrets_key";
    paths = [get_key remove_key];
  }
