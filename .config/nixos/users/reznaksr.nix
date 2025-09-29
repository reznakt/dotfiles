{ config, pkgs, ... }:

let
  username = "reznaksr";
in
{
  home = {
    username = username;
    homeDirectory = "/home/${username}";
    stateVersion = "25.05";

    packages = with pkgs; [
      gnome-tweaks
      gnome-extension-manager
      firefox
    ];
  };
}
