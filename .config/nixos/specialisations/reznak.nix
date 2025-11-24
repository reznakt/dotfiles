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

  nixpkgs.config.permittedInsecurePackages = [
    "electron-36.9.5"
  ];

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
      clean = {
        enable = true;
        extraArgs = "--keep-since 30d";
      };
    };

    git = {
      enable = true;
      lfs.enable = true;
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
    tlp.enable = true;
    tailscale.enable = true;
    upower.enable = true; # for hyprpanel

    # automounting of usb drives
    gvfs.enable = true;
    udisks2.enable = true;

    greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          command = "Hyprland";
          user = username;
        };
        default_session = initial_session;
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
