{
  lib,
  config,
  pkgs,
  reznak,
  isSpecialisation,
  ...
}:
let
  homeManagerModule = reznak;
  username = "reznak";
in
{
  system.nixos.tags = [ username ];
  home-manager.users.${username} = homeManagerModule;

  sops.secrets = {
    "weatherapi.json" = {
      sopsFile = ../secrets/weatherapi.json;
      format = "json";
      key = "";
      owner = username;
    };
  };

  environment = {
    etc.specialisation = lib.mkIf (isSpecialisation) {
      text = username;
      mode = "0644";
    };

    systemPackages = with pkgs; [
      kbd
      fzf
    ];

    pathsToLink = [
      "/share/applications"
      "/share/xdg-desktop-portal"
    ];
  };

  users.users = {
    ${username} = {
      isNormalUser = true;
      description = "Tomáš Režňák";
      hashedPasswordFile = config.sops.secrets."password-hash-${username}".path;
      extraGroups = [
        "adbusers"
        "audio"
        "docker"
        "gamemode"
        "networkmanager"
        "video"
        "wheel"
      ];
      shell = pkgs.zsh;
    };
  };

  programs = {
    adb.enable = true;
    gamescope.enable = true;
    zsh.enable = true;

    gamemode = {
      enable = true;

      settings = {
        general = {
          renice = 10;
          softrealtime = "on";
        };

        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          gpu_device = 1;
          amd_performance_level = "high";
        };

        custom = {
          start = "notify-send -u low -e -a 'Gamemode' 'Gamemode' 'Optimizations activated'";
          end = "notify-send -u low -e -a 'Gamemode' 'Gamemode' 'Optimizations deactivated'";
        };
      };
    };

    nh = {
      enable = true;
      flake = "/etc/nixos/";
    };

    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };
  };

  services = {
    invidious.enable = true;
    power-profiles-daemon.enable = true;
    tailscale.enable = true;
    upower.enable = true; # for hyprpanel

    # automounting of usb drives
    gvfs.enable = true;
    udisks2.enable = true;

    greetd = {
      enable = true;
      settings = {
        default_session = {
          command =
            let
              mkCmd = prog: args: "${lib.getExe prog} ${lib.concatStringsSep " " args}";
            in
            mkCmd pkgs.tuigreet [
              "--time"
              "--remember"
              "--remember-user-session"
              "--user-menu"
              "--user-menu-min-uid 1000"
              "--asterisks"
              "--asterisks-char •"
              "--cmd ${lib.getExe pkgs.hyprland}"
            ];
        };
      };
    };

    xserver.xkb = {
      layout = "cz";
      variant = "";
    };
  };

  systemd.user.services.mpris-proxy = {
    description = "Mpris proxy";
    after = [
      "network.target"
      "sound.target"
    ];
    wantedBy = [ "default.target" ];
    serviceConfig.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
  };

  security.pam.services = {
    greetd.enableGnomeKeyring = true;
    hyprlock.enableGnomeKeyring = true;
    login.enableGnomeKeyring = true;
  };
}
