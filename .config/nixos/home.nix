{ config, pkgs, ... }:

{
  home = {
    username = "reznak";
    homeDirectory = "/home/reznak";
    stateVersion = "25.05";

    packages = with pkgs; [
      bluemail
      brightnessctl
      btop-rocm
      caprine
      fastfetch
      fd
      ghostty
      grim
      heroic
      hyprpicker
      insomnia
      labymod-launcher
      lsd
      lunar-client
      nixfmt-rfc-style
      playerctl
      pwvucontrol
      ripgrep
      ripgrep
      signal-desktop
      slurp
      spotify
      swaynotificationcenter
      vscode-fhs
      walker
      webcord
      wl-clipboard
      yadm
      adwaita-icon-theme
      bc
      desktop-file-utils
      fzf
      gnome-themes-extra
      go
      inotify-tools
      jq
      libsForQt5.qt5ct
      lurk
      pnpm
      poetry
      pre-commit
      qt6ct
      tmux
      ungoogled-chromium
      virtualenv
      zsh-powerlevel10k
    ];
  };
}
