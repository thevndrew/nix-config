{systemInfo, ...}: {
  imports = [];

  users.users.${systemInfo.user}.extraGroups = ["wheel" "docker"];
  users.extraGroups.docker.members = ["${systemInfo.user}"];

  networking = {
    hostName = systemInfo.hostname;
  };

  system.stateVersion = "23.11"; # Did you read the comment?
}
