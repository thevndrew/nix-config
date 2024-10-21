{inputs, ...}: pkgs: rec {
  users = {
    andrew = {
      name = "andrew";
      shell = pkgs.zsh;
      isNormalUser = true;
      description = "";
      extraGroups = ["networkmanager" "wheel" "podman" "storage" "docker" "vboxusers" "input"];
      # this is packages for nixOS user config.
      # packages = []; # empty because that is managed by home-manager
    };
  };

  git = {
    andrew = {
      extraConfig = {
        core = {
          autoSetupRemote = "true";
          fsmonitor = "true";
        };
      };
      userName = "andrew";
    };
  };

  homeManager = {
    andrew = mkHMdir "andrew";
  };

  mkHMdir = username: let
    homeDirPrefix =
      if pkgs.stdenv.hostPlatform.isDarwin
      then "Users"
      else "home";
    homeDirectory = "/${homeDirPrefix}/${username}";
  in {
    inherit username homeDirectory;
  };
}
