{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}:

let
  username = config.home.username;
  hostname = osConfig.networking.hostName;
in
{
  programs.hyprpanel = {
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

        clock.format = "%a %d. %m. %H:%M:%S";
        launcher.autoDetection = true;
        media.show_active_only = true;
        network.showWifiInfo = true;
        notifications.show_total = true;
        volume.rightClick = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";

        customModules =
          let
            pollingInterval = 1000;
          in
          {
            cava.showActiveOnly = true;
            cpu.pollingInterval = pollingInterval;
            cpuTemp.pollingInterval = pollingInterval;
            ram.labelType = "used/total";

            netstat = {
              dynamicIcon = true;
              pollingInterval = pollingInterval;
            };
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
}
