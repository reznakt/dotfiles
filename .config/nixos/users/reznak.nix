{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}:

let
  username = "reznak";
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
        gnome-themes-extra
        heroic
        home-assistant-cli
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
        pre-commit
        proton-pass
        protonvpn-gui
        pwvucontrol
        qt6ct
        signal-desktop
        socat # for hyprland-events
        sops
        spotify
        ssh-to-age
        teams-for-linux
        tmux
        unzip
        virtualenv
        webcord
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
  };

  wayland.windowManager.hyprland =
    let
      hostname = osConfig.networking.hostName;
    in
    {
      enable = true;

      extraConfig = lib.concatStringsSep "\n" (
        [
          "exec-once = hyprland-events"
          "exec-once = ${lib.getExe pkgs.swaynotificationcenter}"
          "exec-once = ${lib.getExe pkgs.walker} --gapplication-service"
          "exec-once = ${lib.getExe pkgs.steam} -silent"
          "exec-once = ${lib.getExe pkgs.webcord} --start-minimized"
          "exec-once = ${pkgs.caprine}/bin/caprine"
          "exec-once = ${lib.getExe pkgs.spotify}"
          "exec-once = ${lib.getExe pkgs.signal-desktop}"
          "exec-once = ${lib.getExe pkgs.teams-for-linux} --minimized"

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
            "${mainMod}, C, killactive,"
            "${mainMod}, V, togglefloating,"
            "${mainMod}, R, exec, ${lib.getExe pkgs.walker} --modules=applications,calc"
            "${mainMod}, F, fullscreen,"
            "${mainMod}, B, exec, ${browser}"
            "${mainMod}, N, exec, ${pkgs.swaynotificationcenter}/bin/swaync-client --toggle-panel --skip-wait"
            "${mainMod} SHIFT, N, exec, ${pkgs.swaynotificationcenter}/bin/swaync-client --close-all && ${pkgs.swaynotificationcenter}/bin/swaync-client --close-panel"
            "${mainMod}, T, exec, toggle-lights"
            "${mainMod}, L, exec, ${lib.getExe pkgs.hyprlock}"

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
          ];

          layerrule = [
            "blur, waybar"
            "blur, swaync-control-center"
            "ignorezero, swaync-notification-window"
            "ignorezero, swaync"
            "ignorezero, swaync-control-center"
            "blur, swaync-notification-window"
            "animation appleEase, swaync-control-center"
            "blur, swaync"
          ];
        };
    };

  programs = {
    fastfetch.enable = true;
    go.enable = true;

    waybar = {
      enable = true;

      systemd = {
        enable = true;
        target = "graphical-session.target";
      };

      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 24;
          modules-left = [
            "hyprland/workspaces"
            "mpris"
            "gamemode"
            "privacy"
            "custom/xwayland"
          ];
          modules-center = [ "hyprland/window" ];
          modules-right = [
            "tray"
            "backlight"
            "pulseaudio"
            "network"
            "temperature"
            "cpu"
            "memory"
            "custom/gpu-usage"
            "battery"
            "clock"
            "custom/notification"
          ];

          "hyprland/workspaces" = {
            format = "{icon}";
            on-scroll-up = "${pkgs.hyprland}/bin/hyprctl dispatch workspace e+1";
            on-scroll-down = "${pkgs.hyprland}/bin/hyprctl dispatch workspace e-1";
          };

          tray = {
            spacing = 10;
          };

          gamemode = {
            format-alt = "{glyph}";
            icon-size = 16;
          };

          "hyprland/window" = {
            icon = true;
            icon-size = 16;
            separate-outputs = true;
            max-length = 45;
          };

          privacy = {
            icon-spacing = 4;
            icon-size = 14;
            transition-duration = 250;
            modules = [
              {
                type = "screenshare";
                tooltip = true;
                tooltip-icon-size = 24;
              }
              {
                type = "audio-in";
                tooltip = true;
                tooltip-icon-size = 24;
              }
            ];
          };

          mpris = {
            format = "{status_icon} {player_icon} {artist} – {title}";
            player-icons = {
              default = "🎵";
              spotify = " ";
              spotifyd = " ";
              spotify_player = " ";
              firefox = "󰈹";
              vlc = "󰕼";
              chromium = "";
              mpv = "";
            };
            status-icons = {
              playing = "";
              paused = "";
              stopped = "";
            };
            artist-len = 15;
            title-len = 45;
            on-scroll-up = "${lib.getExe pkgs.playerctl} next";
            on-scroll-down = "${lib.getExe pkgs.playerctl} previous";
          };

          backlight = {
            device = "intel_backlight";
            format = "{percent}% 󰛨";
          };

          clock = {
            interval = 1;
            format = "{:%d/%m/%y %H:%M:%S}";
            tooltip-format = "<tt>{calendar}</tt>";
            calendar = {
              mode = "month";
              weeks-pos = "left";
              format = {
                months = "<span color='#ffead3'><b>{}</b></span>";
                days = "<span color='#ecc6d9'><b>{}</b></span>";
                weeks = "<span color='#99ffdd'><b>W{}</b></span>";
                weekdays = "<span color='#ffcc66'><b>{}</b></span>";
                today = "<span color='#ff6699'><b><u>{}</u></b></span>";
              };
            };
          };

          cpu = {
            interval = 2;
            format = "{avg_frequency} GHz ({usage}%) ";
          };

          memory = {
            interval = 2;
            format = "{used} GiB ({percentage}%) ";
          };

          battery = {
            frequency = 10;
            format = "{capacity}% ({time} @ {power:0.2f}W) {icon}";
            format-icons = [
              ""
              ""
              ""
              ""
              ""
            ];
            states = {
              critical = 5;
            };
          };

          network = {
            interval = 5;
            format-wifi = "{essid} {signalStrength}% {icon} ({bandwidthDownBytes} 󰇚 {bandwidthUpBytes} 󰕒)";
            format-ethernet = "{ifname} {icon} ({bandwidthDownBytes} 󰇚 {bandwidthUpBytes} 󰕒)";
            format-disconnected = "Disconnected {icon}";
            format-icons = {
              wifi = "";
              ethernet = "󰈀";
              disconnected = "";
            };
            tooltip-disconnected = " Disconnected";
            tooltip-format = "{icon} {ifname}\n󰩟 address: {ipaddr}/{cidr}\n󰑩 gateway: {gwaddr}\n󰓅 bandwidth: {bandwidthDownBytes} 󰇚 {bandwidthUpBytes} 󰕒";
          };

          pulseaudio = {
            format = "{volume}% {icon}";
            format-bluetooth = "{volume}% {icon}";
            format-muted = "";
            format-icons = {
              headphones = "";
              handsfree = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = [
                ""
                ""
              ];
            };
            on-click = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          };

          temperature = {
            interval = 10;
            thermal-zone = 0;
            format = "{temperatureC}°C ";
          };

          "custom/gpu-usage" = {
            exec = "cat /sys/class/drm/card*/device/gpu_busy_percent 2> /dev/null | head -n 1";
            format = "GPU: {}%";
            return-type = "";
            interval = 2;
          };

          "custom/notification" = {
            tooltip = false;
            escape = true;
            format = "{} {icon}";
            format-icons = {
              notification = "󱅫";
              none = "";
              "dnd-notification" = " ";
              "dnd-none" = "󰂛";
              "inhibited-notification" = " ";
              "inhibited-none" = "";
              "dnd-inhibited-notification" = " ";
              "dnd-inhibited-none" = " ";
            };
            return-type = "json";
            exec = "${pkgs.swaynotificationcenter}/bin/swaync-client -swb";
            on-click = "${pkgs.swaynotificationcenter}/bin/swaync-client -t -sw";
            on-click-right = "${pkgs.swaynotificationcenter}/bin/swaync-client -d -sw";
          };

          "custom/xwayland" = {
            format = "{}";
            exec = "${pkgs.hyprland}/bin/hyprctl activewindow | grep -q 'xwayland: 1' && echo ''";
            signal = 1;
            tooltip-format = "XWayland";
          };
        };
      };

      style = ''
        * {
            font-family: "Ubuntu Nerd Font";
            font-size: 12px;
            border-radius: 6px;
            padding: 1px 0;
            margin: 0 3px;
            transition: all 0.3s ease;
        }

        window#waybar {
            background: transparent;
            color: #ECEFF4;
            box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.6);
        }

        #workspaces button {
            background-color: transparent;
            color: #81A1C1;
            padding: 4px 8px;
            border: 2px solid transparent;
            font-weight: bold;
            transition: color 0.3s, border-bottom 0.3s;
        }

        #workspaces button.focused {
            color: #A3BE8C;
            border-bottom: 2px solid #A3BE8C;
        }

        #workspaces button:hover {
            color: #88C0D0;
        }

        #clock, #battery, #cpu, #memory, #network, #pulseaudio, #mpris, #tray, #mode {
            background-color: rgba(46, 52, 64, 0.8);
            color: #D8DEE9;
            border-radius: 6px;
            padding: 6px 10px;
            margin: 0 6px;
            box-shadow: inset 0px 0px 4px rgba(0, 0, 0, 0.3);
        }

        #clock {
            font-weight: bold;
            background-color: #4C566A;
            color: #EBCB8B;
        }

        #cpu, #memory {
            background-color: #5E81AC;
            color: #ECEFF4;
        }

        #cpu:hover, #memory:hover {
            background-color: #88C0D0;
            color: #2E3440;
        }

        #battery.charging {
            background-color: #A3BE8C;
            color: #2E3440;
        }

        #battery.discharging.critical {
            background-color: #FF0000;
        }

        #network.disconnected {
            background-color: #BF616A;
            color: #ECEFF4;
            font-weight: bold;
        }

        #pulseaudio {
            background-color: #B48EAD;
            color: #ECEFF4;
        }

        #pulseaudio:hover {
            background-color: #D08770;
            color: #2E3440;
        }

        #mpris {
            background-color: #282E3A;
        }

        #mpris:hover {
          opacity: 0.8;
        }

        #mpris.firefox {
            background-color: #FF7731;
        }

        #mpris.spotify, #mpris.spotifyd, #mpris.spotify_player {
            background-color: #18C16A;
            color: black;
        }

        #mpris.chromium {
            background-color: #588DE2;
        }

        #mpris.vlc {
            background-color: #EB7000;
        }

        #mpris.mpv {
            background-color: #400041;
        }

        #tray {
            background-color: rgba(46, 52, 64, 0.8);
            padding: 4px 6px;
            border-radius: 6px;
        }

        #tray .icon:hover {
            color: #88C0D0;
        }

        #custom-xwayland {
          font-size: 16px;
        }
      '';
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
            aaron-bond.better-comments
            arrterian.nix-env-selector
            charliermarsh.ruff
            editorconfig.editorconfig
            github.copilot
            github.copilot-chat
            jnoortheen.nix-ide
            k--kato.intellij-idea-keybindings
            kchusap.opl
            ms-python.debugpy
            ms-python.python
            ms-python.vscode-pylance
            ms-toolsai.datawrangler
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
