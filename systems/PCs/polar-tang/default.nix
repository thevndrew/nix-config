{
  lib,
  system-modules,
  username,
  ...
}: {
  imports = with system-modules; [
    ../PCs.nix
  ];
  vndrewMods = {
    cockpit.enable = false;
    networking.enable = false;
    samba.sharing.enable = false;
    virtualisation.enable = false;
    wsl = {
      enable = true;
      user = username;
    };
  };

  users.users.${username}.uid = lib.mkForce 1001;

  # users.users.${username}.extraGroups = ["wheel" "docker"];
  users.extraGroups.docker.members = [username];
}
