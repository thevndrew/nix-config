{ config, currentSystemName, currentSystemHome, ... }:
let
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  xdg = {
    enable = true;
    configFile = {
      # Nothing here for now...
    };
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';

    ".ssh/github_link".source = link "${currentSystemHome}/.ssh/${currentSystemName}";
    ".ssh/github_link".onChange = ''cat ~/.ssh/github_link > ~/.ssh/github && chmod 600 ~/.ssh/github'';
    ".ssh/github_link.pub".source = link "${currentSystemHome}/.ssh/${currentSystemName}.pub";
    ".ssh/github_link.pub".onChange = ''cat ~/.ssh/github_link.pub > ~/.ssh/github.pub && chmod 600 ~/.ssh/github.pub'';
  };
}
