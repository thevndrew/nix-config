{user, ...}: {
  users.users.${user}.extraGroups = ["wheel" "docker"];
  users.extraGroups.docker.members = ["${user}"];
}
