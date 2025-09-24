{ config, pkgs, ... }:

{
  home = {
    username = "reznak";
    homeDirectory = "/home/reznak";
    stateVersion = "25.05";

    packages =
      with pkgs;
      [
        adwaita-icon-theme
        androidenv.androidPkgs.platform-tools
        bc
        bluemail
        brightnessctl
        caprine
        desktop-file-utils
        gnome-themes-extra
        grim
        heroic
        home-assistant-cli
        hyprpicker
        inotify-tools
        insomnia
        labymod-launcher
        libnotify
        libsForQt5.qt5ct
        lunar-client
        lurk
        lutris
        nixfmt-rfc-style
        obsidian
        octaveFull
        playerctl
        pre-commit
        proton-pass
        protonvpn-gui
        pwvucontrol
        qt6ct
        signal-desktop
        slurp
        spotify
        swaynotificationcenter
        tmux
        virtualenv
        walker
        webcord
        wl-clipboard
        yadm
        zsh-powerlevel10k
        (
          let
            cplex-with-installer = cplex.override {
              releasePath = ./cplex.bin;
            };
          in
          cplex-with-installer.overrideAttrs (old: {
            preInstall = "mkdir -p $out/doc $out/license";
            buildInputs = old.buildInputs ++ [ curl ];
          })
        )
      ]
      ++ map (
        fileName:
        pkgs.writeShellScriptBin (pkgs.lib.strings.removeSuffix ".sh" fileName) (
          builtins.readFile (./scripts + "/${fileName}")
        )
      ) (builtins.attrNames (builtins.readDir ./scripts));
  };

  programs = {
    fastfetch.enable = true;
    go.enable = true;

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
            arrterian.nix-env-selector
            charliermarsh.ruff
            editorconfig.editorconfig
            github.copilot
            github.copilot-chat
            jnoortheen.nix-ide
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
          "github.copilot.chat.agent.autoFix" = true;
          "github.copilot.nextEditSuggestions.enabled" = true;
          "python.analysis.typeCheckingMode" = "strict";
          "python.languageServer" = "Pylance";
          "terminal.integrated.cursorBlinking" = true;
          "terminal.integrated.fontLigatures.enabled" = true;
          "terminal.integrated.smoothScrolling" = true;
          "terminal.integrated.stickyScroll.enabled" = false;
          "update.showReleaseNotes" = false;
          "vsicons.dontShowNewVersionMessage" = true;
          "workbench.colorTheme" = "Material Theme Darker";
          "workbench.iconTheme" = "vscode-icons";
          "workbench.list.smoothScrolling" = true;
          "workbench.startupEditor" = "none";
        };
      };
    };

    librewolf = {
      enable = true;
      settings = {
        "accessibility.force_disabled" = 1;
        "browser.aboutConfig.showWarning" = false;
        "browser.cache.disk.enable" = false;
        "browser.cache.memory.enable" = true;
        "browser.sessionstore.resume_from_crash" = false;
        "browser.theme.content-theme" = 0;
        "browser.translations.enable" = false;
        "browser.urlbar.trimHttps" = false;
        "browser.urlbar.trimURLs" = false;
        "browser.vpn_promo.enabled" = false;
        "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
        "extensions.pocket.enabled" = false;
        "extensions.update.autoUpdateDefault" = true;
        "extensions.update.enabled" = true;
        "findbar.highlightAll" = true;
        "font.name.monospace.x-western" = "UbuntuMono Nerd Font Mono";
        "font.name.sans-serif.x-western" = "UbuntuSans Nerd Font";
        "font.name.serif.x-western" = "Ubuntu Nerd Font";
        "full-screen-api.warning.timeout" = 0;
        "general.autoScroll" = true;
        "general.smoothScroll" = true;
        "identity.fxaccounts.enabled" = true;
        "pdfjs.viewerCssTheme" = 2;
        "privacy.donottrackheader.enabled" = true;
        "privacy.fingerprintingProtection" = true;
        "privacy.resistFingerprinting" = true;
        "security.OCSP.enable" = true;
        "webgl.disabled" = true;
      };
    };

    freetube = {
      enable = true;
      settings = {
        "app.closeToTray" = true;
        "app.minimizeToTray" = true;
        "app.startupBehavior" = "continue-where-left-off";
        "app.theme" = "dark";
        "backendFallback" = false;
        "backendPreference" = "local";
        "baseTheme" = "catppuccinMocha";
        "checkForBlogPosts" = false;
        "checkForUpdates" = false;
        "defaultQuality" = "2160";
        "externalLinkHandling" = "openLinkAfterPrompt";
        "generalAutoLoadMorePaginatedItemsEnabled" = true;
        "hideHeaderLogo" = true;
        "mainColor" = "Blue";
        "player.defaultQuality" = "high";
        "player.hardwareAcceleration" = true;
        "region" = "CZ";
        "useDeArrowThumbnails" = true;
        "useDeArrowTitles" = true;
        "useRssFeeds" = true;
        "useSponsorBlock" = true;
        "videoVolumeMouseScroll" = false;
      };
    };

    tmux = {
      enable = true;
      clock24 = true;
      keyMode = "vi";
      mouse = true;
    };

    lsd = {
      enable = true;
      enableZshIntegration = true;
    };

    mpv = {
      enable = true;
      scripts = with pkgs.mpvScripts; [ mpris ];
    };

    git = {
      enable = true;
      lfs.enable = true;
      diff-so-fancy.enable = true;
    };

    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withNodeJs = true;
      withPython3 = true;
      withRuby = true;
      extraPackages = with pkgs; [
        gcc
        jq
        ripgrep
      ];
    };

    btop = {
      enable = true;
      package = pkgs.btop-rocm;
    };

    ghostty = {
      enable = true;
      enableZshIntegration = true;
      installBatSyntax = true;
      installVimSyntax = true;
    };
  };

  services = {
    gnome-keyring.enable = true;
    hypridle.enable = true;
    hyprpolkitagent.enable = true;
    playerctld.enable = true;
    syncthing.enable = true;
    wluma.enable = true;

    udiskie = {
      enable = true;
      settings = {
        program_options = {
          file_manager = "${pkgs.yazi}/bin/yazi";
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
