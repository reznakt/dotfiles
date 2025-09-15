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
      lutris
      nixfmt-rfc-style
      nodejs # for neovim copilot plugin
      playerctl
      pnpm
      poetry
      pre-commit
      proton-pass
      protonvpn-gui
      pwvucontrol
      qt6ct
      ripgrep
      signal-desktop
      slurp
      spotify
      swaynotificationcenter
      tmux
      ungoogled-chromium
      virtualenv
      walker
      webcord
      wl-clipboard
      yadm
      zsh-powerlevel10k
    ];
  };

  programs = {
    yazi = {
      enable = true;
      enableZshIntegration = true;
      plugins = with pkgs.yaziPlugins; {
        rsync = rsync;
        chmod = chmod;
        git = git;
        sudo = sudo;
        ouch = ouch;
        glow = glow;
        diff = diff;
        duckdb = duckdb;
        bypass = bypass;
        mediainfo = mediainfo;
        full-border = full-border;
        rich-preview = rich-preview;
      };
    };

    vscode = {
      enable = true;
      mutableExtensionsDir = false;
      package = pkgs.vscode-fhs;
      profiles.default = {
        enableExtensionUpdateCheck = true;
        enableUpdateCheck = false;
        # prefer packages from nixpkgs when available, fallback to marketplace
        extensions = (
          with pkgs.vscode-marketplace;
          with pkgs.vscode-extensions;
          [
            aaron-bond.better-comments
            charliermarsh.ruff
            editorconfig.editorconfig
            github.copilot
            github.copilot-chat
            k--kato.intellij-idea-keybindings
            ms-python.debugpy
            ms-python.python
            ms-python.vscode-pylance
            ms-toolsai.jupyter
            ms-toolsai.jupyter-keymap
            ms-toolsai.jupyter-renderers
            ms-vscode-remote.remote-containers
            pflannery.vscode-versionlens
            sanaajani.taskrunnercode
            t3dotgg.vsc-material-theme-but-i-wont-sue-you
            usernamehw.errorlens
            vscode-icons-team.vscode-icons
            jnoortheen.nix-ide
            yoavbls.pretty-ts-errors
          ]
        );
        userSettings = {
          "editor.cursorBlinking" = "smooth";
          "editor.fontFamily" = "JetBrains Mono";
          "editor.fontLigatures" = true;
          "editor.fontSize" = 13;
          "editor.linkedEditing" = true;
          "editor.smoothScrolling" = true;
          "explorer.sortOrder" = "type";
          "files.autoSave" = "afterDelay";
          "python.analysis.typeCheckingMode" = "strict";
          "python.languageServer" = "Pylance";
          "terminal.integrated.cursorBlinking" = true;
          "terminal.integrated.fontLigatures.enabled" = true;
          "terminal.integrated.smoothScrolling" = true;
          "vsicons.dontShowNewVersionMessage" = true;
          "workbench.colorTheme" = "Material Theme Darker";
          "workbench.iconTheme" = "vscode-icons";
          "workbench.list.smoothScrolling" = true;
          "workbench.secondarySideBar.defaultVisibility" = "visible";
          "workbench.startupEditor" = "none";
          "github.copilot.nextEditSuggestions.enabled" = true;
          "github.copilot.chat.agent.autoFix" = true;
        };
      };
    };
  };

  services.hyprpolkitagent.enable = true;

  services.udiskie = {
    enable = true;
    settings = {
      program_options = {
        file_manager = "${pkgs.yazi}/bin/yazi";
      };
    };
  };
}
