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
    ];
  };

  programs = {
    chromium.enable = true;
    onlyoffice.enable = true;

    git = {
      enable = true;
      lfs.enable = true;
    };

    vscode = {
      enable = true;
      package = pkgs.vscode-fhs;
      profiles.default = {
        enableExtensionUpdateCheck = true;
        enableUpdateCheck = false;
      };
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      clock-show-weekday = true;
      clock-show-seconds = true;
      clock-format = "24h";
      color-scheme = "prefer-dark";
      gtk-theme = "Adwaita-dark";
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
    };

    "org/gnome/shell" = {
      enabled-extensions = [
        "appindicatorsupport@rgcjonas.gmail.com"
        "blur-my-shell@aunetx"
        "dash-to-dock@micxgx.gmail.com"
      ];
    };
  };
}
