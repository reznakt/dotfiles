{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}:

let
  username = "reznak";
  hostname = osConfig.networking.hostName;
in
{
  home = {
    username = username;
    homeDirectory = "/home/${username}";
    stateVersion = "25.05";

    packages =
      with pkgs;
      [
        adwaita-icon-theme
        age
        androidenv.androidPkgs.platform-tools
        bc
        caprine
        desktop-file-utils
        gcr # for gnome-keyring
        gnome-themes-extra
        heroic
        home-assistant-cli
        inotify-tools
        insomnia
        jq # for kill-active-window
        labymod-launcher
        libnotify
        libsForQt5.qt5ct
        lunar-client
        lurk
        lutris
        nixfmt-rfc-style
        obsidian
        octaveFull
        pre-commit
        proton-pass
        protonmail-desktop
        protonvpn-gui
        pwvucontrol
        qt6Packages.qt6ct
        signal-desktop
        socat # for hyprland-events
        sops
        spotify
        ssh-to-age
        teams-for-linux
        tmux
        unzip
        virtualenv
        wl-clipboard
        yadm
        zsh-powerlevel10k
        (
          let
            cplex-with-installer = cplex.override {
              releasePath = ../assets/cplex.bin;
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
          builtins.readFile (../scripts + "/${fileName}")
        )
      ) (builtins.attrNames (builtins.readDir ../scripts));

    file = {
      # https://github.com/nix-community/home-manager/issues/322
      ".ssh/config" = {
        target = ".ssh/.config_source";
        onChange = ''cat ~/.ssh/.config_source > ~/.ssh/config && chmod 400 ~/.ssh/config'';
      };
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.variables = [ "--all" ];

    extraConfig = lib.concatStringsSep "\n" (
      [
        "exec-once = hyprland-events"
        "exec-once = ${lib.getExe pkgs.walker} --gapplication-service"
        "exec-once = ${lib.getExe pkgs.steam} -silent"
        "exec-once = ${lib.getExe pkgs.webcord} --start-minimized"
        "exec-once = ${pkgs.caprine}/bin/caprine"
        "exec-once = ${lib.getExe pkgs.spotify}"
        "exec-once = ${lib.getExe pkgs.signal-desktop}"
        "exec-once = ${lib.getExe pkgs.teams-for-linux} --minimized"
        "exec-once = while true; do ${lib.getExe pkgs.thunderbird}; done"

        "permission = ${lib.getExe pkgs.grim}, screencopy, allow"
        "permission = ${lib.escapeRegex (lib.getExe config.programs.hyprlock.package)}, screencopy, allow"
        "permission = ${pkgs.xdg-desktop-portal-hyprland}/libexec/.xdg-desktop-portal-hyprland-wrapped, screencopy, allow"

        "gesture = 3, horizontal, workspace"
      ]
      # https://github.com/hyprwm/Hyprland/issues/7608
      ++ lib.optionals (hostname == "desktop") [
        "workspace = 1,monitor:DP-3,default:true"
      ]
    );

    settings =
      let
        terminal = "${lib.getExe pkgs.ghostty}";
        browser = "${pkgs.xdg-utils}/bin/xdg-open http://";
        mainMod = "SUPER";
        monitorConfig = {
          laptop = [ "eDP-1, 1920x1080@60, 0x0, 1" ];
          desktop = [
            "HDMI-A-1, 1920x1080@71.91, 0x0, 1"
            "DP-3, 1920x1080@180, 1920x0, 1, bitdepth, 10"
            "DP-1, 1920x1080@71.91, 3840x0, 1"
          ];
        };
      in
      {
        monitor = monitorConfig.${hostname};

        env = [
          "__GL_MaxFramesAllowed,1"
          "__GL_VRR_ALLOWED,1"
          "__NV_PRIME_RENDER_OFFLOAD,1"
          "_JAVA_AWT_WM_NONREPARENTING,1"
          "CLUTTER_BACKEND,wayland"
          "ELECTRON_OZONE_PLATFORM_HINT,auto"
          "GDK_BACKEND,wayland,x11"
          "GTK_THEME,Adwaita-dark"
          "MOZ_DISABLE_RDD_SANDBOX,1"
          "MOZ_ENABLE_WAYLAND,1"
          "NVD_BACKEND,direct"
          "PROTON_ENABLE_NGX_UPDATER,1"
          "QT_AUTO_SCREEN_SCALE_FACTOR,1"
          "QT_QPA_PLATFORM,wayland"
          "QT_QPA_PLATFORMTHEME,qt5ct:qt6ct"
          "SDL_VIDEODRIVER,wayland,x11,windows"
          "WLR_DRM_NO_ATOMIC,1"
          "WLR_RENDERER_ALLOW_SOFTWARE,1"
          "WLR_USE_LIBINPUT,1"
          "XCURSOR_SIZE,24"
          "XCURSOR_THEME,Adwaita"
          "XDG_CURRENT_DESKTOP,Hyprland"
          "XDG_SESSION_DESKTOP,Hyprland"
          "XDG_SESSION_TYPE,wayland"
        ];

        general = {
          gaps_in = 5;
          gaps_out = 5;
          border_size = 1;
          "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
          "col.inactive_border" = "rgba(595959aa)";
          resize_on_border = true;
          allow_tearing = false;
          layout = "master";
        };

        decoration = {
          rounding = 10;
          active_opacity = 1.0;
          inactive_opacity = 0.9;

          shadow = {
            enabled = true;
            range = 20;
            render_power = 3;
            color = "rgba(1a1a1aee)";
          };

          blur = {
            enabled = true;
            size = 8;
            passes = 1;
            vibrancy = 0.1696;
            popups = true;
          };
        };

        animations = {
          enabled = true;
          bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "borderangle, 1, 8, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
          ];
        };

        master = {
          new_status = "slave";
          mfact = 0.5;
        };

        misc = {
          vrr = 1;
          font_family = "JetBrains Mono";
          splash_font_family = "JetBrains Mono";
          allow_session_lock_restore = true;
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
        };

        input = {
          kb_layout = "cz,us";
          kb_options = "grp:win_space_toggle";
          numlock_by_default = true;
          follow_mouse = 2;
          resolve_binds_by_sym = true;
          sensitivity = 0;

          touchpad = {
            natural_scroll = true;
            middle_button_emulation = true;
            disable_while_typing = false;
            drag_lock = true;
          };
        };

        gestures = {
          workspace_swipe_direction_lock = false;
        };

        ecosystem = {
          no_donation_nag = true;
          no_update_news = true;
          enforce_permissions = true;
        };

        experimental = {
          xx_color_management_v4 = true;
        };

        binde = [
          "${mainMod}, Q, exec, ${terminal}"
          "ALT, Tab, cyclenext"
          "ALT, Tab, bringactivetotop"
        ];

        bind = [
          "${mainMod}, C, exec, kill-active-window"
          "${mainMod}, V, togglefloating,"
          "${mainMod}, R, exec, ${lib.getExe pkgs.walker} --modules=applications,calc"
          "${mainMod}, N, exec, hyprpanel toggleWindow notificationsmenu"
          "${mainMod}, F, fullscreen,"
          "${mainMod}, B, exec, ${browser}"
          "${mainMod}, T, exec, toggle-lights"
          "${mainMod}, L, exec, ${lib.getExe pkgs.hyprlock}"
          "${mainMod}, M, togglespecialworkspace, mail"

          "${mainMod}, left, movefocus, l"
          "${mainMod}, right, movefocus, r"
          "${mainMod}, up, movefocus, u"
          "${mainMod}, down, movefocus, d"

          "${mainMod}, 1, workspace, 1"
          "${mainMod}, 2, workspace, 2"
          "${mainMod}, 3, workspace, 3"
          "${mainMod}, 4, workspace, 4"
          "${mainMod}, 5, workspace, 5"
          "${mainMod}, 6, workspace, 6"
          "${mainMod}, 7, workspace, 7"
          "${mainMod}, 8, workspace, 8"
          "${mainMod}, 9, workspace, 9"
          "${mainMod}, 0, workspace, 10"

          "${mainMod} SHIFT, 1, movetoworkspace, 1"
          "${mainMod} SHIFT, 2, movetoworkspace, 2"
          "${mainMod} SHIFT, 3, movetoworkspace, 3"
          "${mainMod} SHIFT, 4, movetoworkspace, 4"
          "${mainMod} SHIFT, 5, movetoworkspace, 5"
          "${mainMod} SHIFT, 6, movetoworkspace, 6"
          "${mainMod} SHIFT, 7, movetoworkspace, 7"
          "${mainMod} SHIFT, 8, movetoworkspace, 8"
          "${mainMod} SHIFT, 9, movetoworkspace, 9"
          "${mainMod} SHIFT, 0, movetoworkspace, 10"

          "${mainMod}, S, togglespecialworkspace, magic"
          "${mainMod}, S, movetoworkspace, +0"
          "${mainMod}, S, togglespecialworkspace, magic"
          "${mainMod}, S, movetoworkspace, special:magic"
          "${mainMod}, S, togglespecialworkspace, magic"

          "${mainMod}, mouse_down, workspace, e+1"
          "${mainMod}, mouse_up, workspace, e-1"

          ", Print, exec, ${pkgs.psmisc}/bin/pkill ${lib.getExe pkgs.slurp} || ${lib.getExe pkgs.grim} -g \"$(${lib.getExe pkgs.slurp} -d)\" - | ${pkgs.wl-clipboard}/bin/wl-copy"
          "SHIFT, Print, exec, ${pkgs.psmisc}/bin/pkill ${lib.getExe pkgs.hyprpicker} || ${lib.getExe pkgs.hyprpicker} --autocopy --format=hex --no-fancy"
        ];

        bindel = [
          ", XF86AudioLowerVolume, exec, ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 && ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ", XF86AudioRaiseVolume, exec, ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 && ${pkgs.wireplumber}/bin/wpctl set-volume --limit 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
          ", XF86AudioMute, exec, ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ", XF86MonBrightnessDown, exec, ${lib.getExe pkgs.brightnessctl} set 5%-"
          ", XF86MonBrightnessUp, exec, ${lib.getExe pkgs.brightnessctl} set +5%"
        ];

        bindl = [
          ", XF86AudioPlay, exec, ${lib.getExe pkgs.playerctl} play-pause"
          ", XF86AudioPrev, exec, ${lib.getExe pkgs.playerctl} previous"
          ", XF86AudioNext, exec, ${lib.getExe pkgs.playerctl} next"
        ];

        bindm = [
          "${mainMod}, mouse:272, movewindow"
          "${mainMod}, mouse:273, resizewindow"
        ];

        windowrulev2 = [
          "suppressevent maximize, class:.*"
          "tile, initialTitle:Visual Paradigm"
          "opaque, class:(mpv|firefox)"
          "workspace special:mail silent, class:^(thunderbird)$"
        ];
      };
  };

  programs = {
    fastfetch.enable = true;
    go.enable = true;
    micro.enable = true;
    btop.enable = true;

    onlyoffice = {
      enable = true;
      settings = {
        UITheme = "theme-night";
      };
    };

    ssh = {
      enable = true;
      enableDefaultConfig = false;

      matchBlocks = {
        "*" = {
          forwardAgent = false;
          addKeysToAgent = "no";
          compression = false;
          serverAliveInterval = 0;
          serverAliveCountMax = 3;
          hashKnownHosts = false;
          userKnownHostsFile = "~/.ssh/known_hosts";
          controlMaster = "no";
          controlPath = "~/.ssh/master-%r@%n:%p";
          controlPersist = "no";
        };

        server = {
          hostname = "192.168.0.250";
        };

        aisa = {
          hostname = "aisa.fi.muni.cz";
          user = "xreznak";
        };

        anxur = {
          hostname = "anxur.fi.muni.cz";
          user = "xreznak";
        };

        apollo = {
          proxyJump = "aisa";
          user = "xreznak";
        };

        aura = {
          proxyJump = "aisa";
          user = "xreznak";
        };
      };
    };

    hyprpanel = {
      enable = true;

      settings = {
        bar = {
          launcher.autoDetectIcon = true;
          scalingPriority = "hyprland";

          layouts = {
            "*" = {
              left = [
                "dashboard"
                "workspaces"
                "volume"
                "network"
              ]
              ++ (lib.optionals osConfig.hardware.bluetooth.enable [ "bluetooth" ])
              ++ [
                "media"
                "cava"
              ];

              middle = [
                "systray"
              ];

              right = [
                "netstat"
                "ram"
                "cpu"
                "cputemp"
              ]
              ++ (lib.optionals (hostname == "laptop") [ "battery" ])
              ++ [
                "clock"
                "notifications"
              ];
            };
          };

          clock.format = "%a %d. %m. %H:%M:%S";

          power = {
            low_battery_threshold = 15;
            low_battery_notification = true;
          };
        };

        notifications = {
          position = "top right";
          active_monitor = true;
          show_total = true;
        };

        menus = {
          dashboard = {
            powermenu = {
              avatar = {
                image = "";
                name = osConfig.users.users.${username}.description;
              };
            };

            directories.enabled = false;
            shortcuts.enabled = false;

            stats = {
              enable_gpu = true;
            };
          };
        };

        theme = {
          font.size = "0.85rem";

          bar = {
            menus.opacity = 95;
            opacity = 85;

            buttons = {
              style = "wave";
              spacing = "0.2em";
            };
          };

          ram = {
            label = true;
            icon = true;
            memoryUnit = "GB";
          };

          netstat = {
            dynamic_icon = true;
            truncation = 12;
          };

          notification = {
            opacity = 95;
          };

          buttons = {
            opacity = 85;
          };

          osd = {
            orientation = "horizontal";
            location = "bottom";
            active_monitor = true;
            margin_bottom = "2rem";
          };
        };
      };
    };

    thunderbird = {
      enable = true;
      profiles.default = {
        isDefault = true;
      };
    };

    chromium = {
      enable = true;
      package = pkgs.ungoogled-chromium;
    };

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
            lucasfa.octaveexecution
            aaron-bond.better-comments
            arrterian.nix-env-selector
            charliermarsh.ruff
            dbaeumer.vscode-eslint
            editorconfig.editorconfig
            esbenp.prettier-vscode
            github.copilot
            github.copilot-chat
            hashicorp.terraform
            jnoortheen.nix-ide
            k--kato.intellij-idea-keybindings
            kchusap.opl
            mechatroner.rainbow-csv
            ms-python.debugpy
            ms-python.python
            ms-python.vscode-pylance
            ms-toolsai.datawrangler
            ms-toolsai.jupyter
            ms-toolsai.jupyter-keymap
            ms-toolsai.jupyter-renderers
            ms-vscode-remote.remote-containers
            ms-vscode-remote.remote-ssh
            paulosilva.vsc-octave-debugger
            pflannery.vscode-versionlens
            sanaajani.taskrunnercode
            t3dotgg.vsc-material-theme-but-i-wont-sue-you
            toasty-technologies.octave
            tusindfryd.octave-formatter
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
          "git.autofetch" = true;
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
        "privacy.fingerprintingProtection.overrides" = "+AllTargets,-CSSPrefersColorScheme";
        "privacy.fingerprintingProtection.pbmode" = true;
        "privacy.resistFingerprinting" = false;
        "privacy.resistFingerprinting.pbmode" = false;
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

      signing = {
        signByDefault = true;
        format = "ssh";
        key = "~/.ssh/id_ed25519.pub";
      };

      settings = {
        user = {
          name = "Tomáš Režňák";
          email = "tomas.reznak@volny.cz";
        };

        pull.rebase = true;
        push.autoSetupRemote = true;
      };
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

    ghostty = {
      enable = true;
      enableZshIntegration = true;
      installBatSyntax = true;
      installVimSyntax = true;
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;

      autosuggestion = {
        enable = true;
        strategy = [
          "history"
          "completion"
        ];
      };

      initContent = ''
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
      '';

      oh-my-zsh = {
        enable = true;
        plugins = [
          "bun"
          "colored-man-pages"
          "dirhistory"
          "fancy-ctrl-z"
          "git-auto-fetch"
          "git"
          "history"
          "npm"
          "pip"
          "poetry-env"
          "poetry"
          "rust"
          "safe-paste"
          "zsh-interactive-cd"
        ];
      };

      shellAliases = {
        sops = "EDITOR=micro sops";
        strace = "lurk";
        nix-shell = "nix-shell --run $SHELL";
        nix-develop = "nix develop -c $SHELL";
      };

      history = {
        append = true;
        extended = true;
        ignoreAllDups = true;
        share = true;
      };
    };
  };

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
