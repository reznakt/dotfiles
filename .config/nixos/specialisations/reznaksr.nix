{
  lib,
  config,
  pkgs,
  reznaksr,
  ...
}:
let
  homeManagerModule = reznaksr;
  username = "reznaksr";
in
{
  system.nixos.tags = [ username ];
  home-manager.users.${username} = homeManagerModule;
  environment.etc."specialisation".text = username;

  users.users = {
    ${username} = {
      isNormalUser = true;
      description = "Tomáš Režňák, Sr.";
      extraGroups = [
        "audio"
        "networkmanager"
        "video"
        "wheel"
      ];
    };
  };

  services = {
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
  };
}
