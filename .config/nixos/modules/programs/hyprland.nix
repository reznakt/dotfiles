{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}:

let
  hostname = osConfig.networking.hostName;
in
{
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
          "${mainMod}, C, exec, kill-active-window"
          "${mainMod}, V, togglefloating,"
          "${mainMod}, R, exec, ${lib.getExe pkgs.walker} --modules=applications,calc"
          "${mainMod}, N, exec, hyprpanel toggleWindow notificationsmenu"
          "${mainMod} SHIFT, N, exec, hyprpanel clearNotifications; [ $(hyprpanel isWindowVisible notificationsmenu) = 'true' ] && hyprpanel toggleWindow notificationsmenu"
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
}
