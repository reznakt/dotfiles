{
  lib,
  config,
  pkgs,
  reznak,
  ...
}:
let
  homeManagerModule = reznak;
  username = "reznak";
in
{
  system.nixos.tags = [ username ];
  home-manager.users.${username} = homeManagerModule;
  environment.etc."specialisation".text = username;

  users.users = {
    ${username} = {
      isNormalUser = true;
      description = "Tomáš Režňák";
      extraGroups = [
        "adbusers"
        "audio"
        "docker"
        "gamemode"
        "networkmanager"
        "video"
        "wheel"
      ];
      shell = pkgs.zsh;
    };
  };

  programs = {
    hyprland = {
      enable = true;
      withUWSM = true;
    };
  };

  services = {
    tlp.enable = true;

    greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          command = "uwsm start hyprland-uwsm.desktop";
          user = username;
        };
        default_session = initial_session;
      };
    };
  };
}
