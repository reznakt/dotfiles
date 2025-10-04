{
  lib,
  config,
  pkgs,
  reznak,
  isSpecialisation ? false,
  ...
}:
let
  homeManagerModule = reznak;
  username = "reznak";
in
{
  system.nixos.tags = [ username ];
  home-manager.users.${username} = homeManagerModule;

  environment = {
    etc.specialisation = lib.mkIf (isSpecialisation) {
      text = username;
      mode = "0644";
    };

    systemPackages = with pkgs; [
      kbd
      fzf
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
    waybar.enable = true;
    gamescope.enable = true;

    hyprland = {
      enable = true;
      withUWSM = true;
    };

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

    zsh = {
      enable = true;
      enableCompletion = true;
      enableBashCompletion = true;
      syntaxHighlighting.enable = true;
      vteIntegration = true;

      autosuggestions = {
        enable = true;
        strategy = [
          "history"
          "completion"
        ];
      };

      promptInit = ''
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      '';

      ohMyZsh = {
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
        strace = "lurk";
        ls = "lsd";
        ll = "ls -l";
        la = "ls -A";
        lla = "ll -A";
      };

      histSize = 10000;
      histFile = "$HOME/.zsh_history";
      setOptions = [
        "APPENDHISTORY"
        "EXTENDED_HISTORY"
        "HIST_IGNORE_ALL_DUPS"
        "INC_APPEND_HISTORY"
        "SHARE_HISTORY"
      ];
    };
  };

  services = {
    invidious.enable = true;
    tlp.enable = true;

    # automounting of usb drives
    gvfs.enable = true;
    udisks2.enable = true;

    greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          command = "uwsm start hyprland-uwsm.desktop";
          user = username;
        };
        default_session = initial_session;
      };
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
}
