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
        luanti
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

      ".minetest/games/mineclone2" =
        let
          voxelibre = builtins.fetchGit {
            url = "https://github.com/VoxeLibre/VoxeLibre.git";
            rev = "6a9c0257a795e6786d94363cc6694c2b9c68cfd2";
          };
        in
        {
          source = voxelibre;
          force = true;
        };

      ".minetest/minetest.conf" = {
        text = ''
          connected_glass = true
          creative_mode = true
          enable_build_where_you_stand = false
          enable_damage = true
          enable_fog = true
          enable_waving_leaves = true
          enable_waving_plants = true
          enable_waving_water = true
          fps_max = 180
          fullscreen = true
          keymap_aux1 = SYSTEM_SCANCODE_229
          keymap_backward = SYSTEM_SCANCODE_81
          keymap_forward = SYSTEM_SCANCODE_82
          keymap_inventory = SYSTEM_SCANCODE_8
          keymap_left = SYSTEM_SCANCODE_80
          keymap_right = SYSTEM_SCANCODE_79
          mainmenu_last_selected_world = 1
          mcl_enable_hunger = true
          menu_last_game = mineclone2
          screen_h = 1080
          screen_w = 1920
          server_announce = false
          vsync = true
        '';
        force = true;
      };
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.variables = [ "--all" ];

    plugins = with pkgs.hyprlandPlugins; [
      hyprspace
    ];

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
        "permission = ${lib.getExe pkgs.hyprpicker}, screencopy, allow"
        "permission = ${lib.escapeRegex (lib.getExe config.programs.hyprlock.package)}, screencopy, allow"
        "permission = ${pkgs.xdg-desktop-portal-hyprland}/libexec/.xdg-desktop-portal-hyprland-wrapped, screencopy, allow"
        "permission = ${pkgs.hyprland}/bin/hyprctl, plugin, allow"

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
          "${mainMod}, SUPER_L, overview:toggle"
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
          "opaque, class:^(mpv|firefox|librewolf)$"
          "workspace special:mail silent, class:^thunderbird$"
          "tile, class:steam"
        ];

        layerrule = [
          "blur, ^bar-.*$"
        ];
      };
  };

  programs = {
    fastfetch.enable = true;
    go.enable = true;
    micro.enable = true;

    btop = {
      enable = true;

      settings = {
        color_theme = "Default";
        theme_background = false;
        truecolor = true;
        force_tty = false;

        presets =
          "cpu:1:default,proc:0:default "
          + "cpu:0:default,mem:0:default,net:0:default "
          + "cpu:0:block,net:0:tty";

        vim_keys = false;
        rounded_corners = true;

        graph_symbol = "braille";
        graph_symbol_cpu = "default";
        graph_symbol_gpu = "default";
        graph_symbol_mem = "default";
        graph_symbol_net = "default";
        graph_symbol_proc = "default";

        shown_boxes = "cpu mem net proc";
        update_ms = 500;

        proc_sorting = "cpu lazy";
        proc_reversed = false;
        proc_tree = true;
        proc_colors = true;
        proc_gradient = true;
        proc_per_core = true;
        proc_mem_bytes = true;
        proc_cpu_graphs = true;
        proc_info_smaps = false;
        proc_left = false;
        proc_filter_kernel = true;
        proc_aggregate = true;

        cpu_graph_upper = "total";
        cpu_graph_lower = "total";
        show_gpu_info = "Auto";
        cpu_invert_lower = true;
        cpu_single_graph = false;
        cpu_bottom = false;
        show_uptime = true;
        show_cpu_watts = true;
        check_temp = true;
        cpu_sensor = "Auto";
        show_coretemp = true;
        cpu_core_map = "";
        temp_scale = "celsius";

        base_10_sizes = false;
        show_cpu_freq = true;

        clock_format = " %X";
        background_update = true;
        custom_cpu_name = "";

        disks_filter = "";
        mem_graphs = true;
        mem_below_net = false;
        zfs_arc_cached = true;
        show_swap = true;
        swap_disk = true;
        show_disks = true;
        only_physical = true;
        use_fstab = false;
        zfs_hide_datasets = false;
        disk_free_priv = false;
        show_io_stat = true;
        io_mode = false;
        io_graph_combined = false;
        io_graph_speeds = "";

        net_download = 100;
        net_upload = 20;
        net_auto = false;
        net_sync = false;
        net_iface = "";
        base_10_bitrate = "Auto";

        show_battery = true;
        selected_battery = "Auto";
        show_battery_watts = true;

        log_level = "ERROR";

        nvml_measure_pcie_speeds = true;
        rsmi_measure_pcie_speeds = true;
        gpu_mirror_graph = true;
      };
    };

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

    hyprlock = {
      enable = true;

      settings =
        let
          fontColor = "rgb(255, 255, 255)";
          backgroundColor = "rgba(0, 0, 0, 0.8)";
          outlineColor = "rgb(42, 198, 227)";
        in
        {
          general = {
            hide_cursor = true;
            ignore_empty_input = true;
          };

          auth = {
            "fingerprint:enabled" = true;
          };

          input-field = {
            monitor = "";
            size = "200, 40";
            fade_on_empty = true;
            outline_thickness = 1;
            outer_color = outlineColor;
            inner_color = backgroundColor;
            font_color = fontColor;
            placeholder_text = "";
            fail_text = "$PAMFAIL";
            shadow_passes = 2;
            shadow_size = 5;
          };

          label = [
            {
              monitor = "";
              text = "cmd[update:1000] date +\"%H:%M:%S\"";
              halign = "center";
              valign = "center";
              position = "0, 90";
              font_size = 25;
              color = fontColor;
              shadow_passes = 2;
              shadow_size = 5;
            }
            {
              monitor = "";
              text = "cmd[update:0] date +\"%A, %B %d\"";
              halign = "center";
              valign = "center";
              position = "0, 50";
              font_size = 15;
              color = fontColor;
              shadow_passes = 2;
              shadow_size = 5;
            }
          ];

          background = {
            path = "screenshot";
            blur_passes = 2;
          };
        };
    };

    hyprpanel = {
      enable = true;

      settings = {
        scalingPriority = "hyprland";
        tear = true;

        bar = {
          autoHide = "fullscreen";

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

          cava = {
            showActiveOnly = true;
            framerate = 180;
          };

          clock = {
            format = "%a %d. %m. %H:%M:%S";
          };

          cpu = {
            pollingInterval = 1000;
          };

          cpuPower = {
            round = false;
          };

          launcher = {
            autoDetection = true;
          };

          media = {
            show_active_only = true;
          };

          netstat = {
            dynamicIcon = true;
            pollingInterval = 1000;
          };

          network = {
            showWifiInfo = true;
          };

          notifications = {
            show_total = true;
            hideCountWhenZero = true;
          };

          ram = {
            labelType = "used/total";
          };

          volume = {
            rightClick = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          };

          weather = {
            unit = "metric";
          };

          workspaces = {
            show_numbered = true;
            numbered_active_indicator = "highlight";
          };
        };

        menus = {
          clock = {
            time = {
              military = true;
            };

            weather = {
              interval = 15 * 60 * 1000; # 15 minutes
              unit = "metric";
              location = "Velke Mezirici, Czechia";
              key = osConfig.sops.secrets."weatherapi.json".path;
            };
          };

          dashboard = {
            powermenu = {
              avatar = {
                name = osConfig.users.users.${username}.description;
              };
            };

            directories.enabled = false;
            shortcuts.enabled = false;

            stats = {
              enable_gpu = true;
            };
          };

          media = {
            displayTime = true;
            displayTimeTooltip = true;
          };

          power = {
            lowBatteryNotification = true;
            lowBatteryThreshold = 15;
          };

          volume = {
            raiseMaximumVolume = true;
          };
        };

        notifications = {
          active_monitor = true;
        };

        theme = {
          font.size = "0.85rem";

          bar = {
            opacity = 50;

            buttons = {
              style = "wave";
              spacing = "0.2em";
            };

            menus = {
              enableShadow = true;
            };
          };

          osd = {
            orientation = "horizontal";
            location = "bottom";
            active_monitor = true;
            margins = "5rem";
            enableShadow = true;
          };

          notification = {
            enableShadow = true;
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

      enableBashIntegration = true;
      enableZshIntegration = true;

      settings = {
        classic = false;
        date = "date";
        dereference = false;
        header = false;
        hyperlink = "never";
        indicators = true;
        layout = "grid";
        literal = false;
        no-symlink = false;
        permission = "rwx";
        recursion.enabled = false;
        size = "default";
        symlink-arrow = "->";
        total-size = false;

        blocks = [
          "permission"
          "user"
          "size"
          "date"
          "name"
        ];

        color = {
          when = "auto";
          theme = "default";
        };

        icons = {
          when = "auto";
          theme = "fancy";
          separator = " ";
        };

        sorting = {
          column = "name";
          reverse = false;
          dir-grouping = "first";
        };

        truncate-owner = {
          after = 15;
          marker = "...";
        };
      };
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

      enableBashIntegration = false;
      enableZshIntegration = true;
      installBatSyntax = true;
      installVimSyntax = true;

      settings = {
        background-opacity = 0.5;
        background = "#202020";
        bold-is-bright = false;
        confirm-close-surface = false;

        cursor-opacity = 0.75;
        cursor-style-blink = true;
        cursor-style = "underline";

        font-family = "JetBrains Mono";
        font-size = 10;

        resize-overlay = "never";
        scrollback-limit = 10 * 1000 * 1000;
        shell-integration-features = "no-cursor";

        window-decoration = false;
        window-padding-x = 5;
        window-padding-y = 3;
      };
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

  xdg = {
    configFile = {
      "hypr/xdph.conf".text = ''
        screencopy {
          allow_token_by_default = true
          max_fps = 0  # no limit
        }
      '';
    };
  };
}
