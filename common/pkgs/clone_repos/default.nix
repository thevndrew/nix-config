{pkgs, ...}: let
  repoList = ./repos.yml;
in
  pkgs.writeShellApplication {
    name = "clone_repos";
    runtimeInputs = with pkgs; [yq git];
    text = ''
      set +o errexit

      # Function to clone a repository if it doesn't already exist
      clone_if_not_exists() {
          local REPO_URL="$1"
          local CLONE_DIR="$2"

          [ ! -d "$CLONE_DIR" ] && git clone "$REPO_URL" "$CLONE_DIR" || echo "Directory '$CLONE_DIR' already exists. Skipping clone."
      }

      mkdir_if_not_exists() {
          local DIR
          DIR=$(dirname "$1")

          [ ! -d "$DIR" ] && mkdir -pv "$DIR"
      }

      REPOS=()
      while IFS='''''' read -r line;
      do
          REPOS+=("$line");
      done < <(yq -r '.repo_list | keys[]' "${repoList}")

      for REPO in "''${REPOS[@]}";
      do
          REPO_DIR=$(yq -r ".repo_list.$REPO.directory" "${repoList}")
          REPO_URL=$(yq -r ".repo_list.$REPO.url" "${repoList}")
          mkdir_if_not_exists "$HOME/$REPO_DIR"
          clone_if_not_exists "$REPO_URL" "$HOME/$REPO_DIR"
      done

      set +o nounset
      set +o pipefail
    '';
  }
