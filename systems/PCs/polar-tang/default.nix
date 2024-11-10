{
  lib,
  system-modules,
  username,
  ...
}: let
  wslPass = "$6$90MQYhLKTQJ71Zw9$WrsMNytjnVmZcKNwuWg3grXPsfC2LTw5wt7QGcHc9A5fJUIhskOhJd1L0s.E.VRgpzeuckuEgrojxqqkch51V0";
in {
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

  users.users.${username} = {
    uid = lib.mkForce 1001;
    hashedPassword = wslPass;
    hashedPasswordFile = lib.mkForce null;
  };

  users.users.root = {
    hashedPassword = wslPass;
    hashedPasswordFile = lib.mkForce null;
  };

  # users.users.${username}.extraGroups = ["wheel" "docker"];
  users.extraGroups.docker.members = [username];
}
