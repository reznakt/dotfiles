{ config, pkgs, lib, ... }:

{
  services = {
    gnome-keyring.enable = true;
    hyprpolkitagent.enable = true;
    playerctld.enable = true;
    syncthing.enable = true;
    ssh-agent.enable = true;
    trayscale.enable = true;

    protonmail-bridge = {
      enable = true;
      extraPackages = with pkgs; [ gnome-keyring ];
    };

    udiskie = {
      enable = true;
      settings = {
        program_options = {
          file_manager = lib.getExe pkgs.yazi;
        };
      };
    };

    hyprpaper = {
      enable = true;
      settings =
        let
          wallpaper = "~/.wallpaper.jpg";
        in
        {
          preload = [ wallpaper ];
          wallpaper = [ ", ${wallpaper}" ];
        };
    };
  };
}
