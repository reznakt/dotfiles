{ config, pkgs, ... }:

{
  home = {
    username = "reznak";
    homeDirectory = "/home/reznak";
    stateVersion = "25.05";

    packages = with pkgs; [
      adwaita-icon-theme
      bc
      bluemail
      brightnessctl
      btop-rocm
      caprine
      desktop-file-utils
      fastfetch
      fd
      fzf
      ghostty
      gnome-themes-extra
      go
      grim
      heroic
      hyprpicker
      inotify-tools
      insomnia
      jq
      labymod-launcher
      libsForQt5.qt5ct
      lsd
      lunar-client
      lurk
      nixfmt-rfc-style
      nodejs # for neovim copilot plugin
      playerctl
      pnpm
      poetry
      pre-commit
      pwvucontrol
      qt6ct
      ripgrep
      ripgrep
      signal-desktop
      slurp
      spotify
      swaynotificationcenter
      tmux
      ungoogled-chromium
      virtualenv
      vscode-fhs
      walker
      webcord
      wl-clipboard
      yadm
      zsh-powerlevel10k
    ];
  };
}
