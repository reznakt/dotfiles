{
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [ ./hardware-configuration.nix ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    consoleLogLevel = 3;

    loader = {
      timeout = 2;
      efi.canTouchEfiVariables = true;

      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
        theme = "${pkgs.catppuccin-grub}/";
        configurationLimit = 30;
        gfxmodeEfi = "1920x1080";
      };
    };

    kernelParams = [
      "quiet"
      "splash"
      "udev.log_priority=3"
      "rd.systemd_show_status=auto"
    ];

    plymouth = {
      enable = true;
      theme = "spinner";
    };

    initrd = {
      verbose = false;
      compressor = "cat";

      systemd = {
        enable = true;
        extraBin.setleds = "${pkgs.kbd}/bin/setleds";

        services.setleds = {
          description = "Set keyboard LEDs on TTYs";
          wantedBy = [ "initrd.target" ];
          before = [ "initrd.target" ];
          unitConfig.DefaultDependencies = "no";
          serviceConfig.Type = "oneshot";
          script = ''
            for tty in /dev/tty[1-6]; do
              if [ -e "$tty" ]; then
                setleds -D +num < "$tty"
              fi
            done
          '';
        };
      };
    };
  };

  fileSystems."/".options = [
    "noatime"
    "x-systemd.device-timeout=0"
  ];

  networking = {
    networkmanager.enable = true;
    nftables.enable = true;
    firewall.enable = true;
  };

  time.timeZone = "Europe/Prague";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "cs_CZ.UTF-8";
      LC_IDENTIFICATION = "cs_CZ.UTF-8";
      LC_MEASUREMENT = "cs_CZ.UTF-8";
      LC_MONETARY = "cs_CZ.UTF-8";
      LC_NAME = "cs_CZ.UTF-8";
      LC_NUMERIC = "cs_CZ.UTF-8";
      LC_PAPER = "cs_CZ.UTF-8";
      LC_TELEPHONE = "cs_CZ.UTF-8";
      LC_TIME = "cs_CZ.UTF-8";
    };
  };

  console.useXkbConfig = true;

  users.users.reznak = {
    isNormalUser = true;
    description = "Tomáš Režňák";
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

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [ kbd fzf ];

  programs = {
    adb.enable = true;
    waybar.enable = true;
    gamescope.enable = true;
    nix-ld.enable = true;

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

  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  services = {
    fstrim.enable = true;
    fwupd.enable = true;
    gnome.gnome-keyring.enable = true;
    gvfs.enable = true;
    invidious.enable = true;
    openssh.enable = true;
    playerctld.enable = true;
    preload.enable = true;
    systembus-notify.enable = true;
    tlp.enable = true;
    udisks2.enable = true;

    earlyoom = {
      enable = true;
      enableNotifications = true;
    };

    greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          command = "uwsm start hyprland-uwsm.desktop";
          user = "reznak";
        };
        default_session = initial_session;
      };
    };

    kmscon = {
      enable = true;
      fonts = [
        {
          name = "JetBrainsMono Nerd Font";
          package = pkgs.nerd-fonts.jetbrains-mono;
        }
      ];
      extraConfig = "font-size=10";
      hwRender = true;
      useXkbConfig = true;
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      audio.enable = true;
      wireplumber.enable = true;
      jack.enable = true;
    };

    xserver.xkb = {
      layout = "cz";
      variant = "";
    };
  };

  security = {
    rtkit.enable = true;
    polkit.enable = true;

    pam = {
      u2f = {
        enable = true;
        settings = {
          authfile = "/etc/u2f-keys";
          cue = true;
        };
      };

      services = {
        login.u2fAuth = true;
        polkit-1.u2fAuth = true;
        su.u2fAuth = true;
        sudo.u2fAuth = true;

        greetd.enableGnomeKeyring = true;

        hyprlock = {
          enableGnomeKeyring = true;
          u2fAuth = true;
        };
      };
    };
  };

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
    };
    optimise = {
      automatic = true;
      dates = "daily";
    };
  };

  fonts = {
    enableDefaultPackages = true;
    packages =
      with pkgs;
      [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-emoji
        google-fonts
      ]
      ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  systemd = {
    services = {
      systemd-udev-settle.enable = false;
      systemd-journald.serviceConfig.SystemMaxUse = "50M";
      NetworkManager-wait-online.enable = false;
    };
    user.services = {
      mpris-proxy = {
        description = "Mpris proxy";
        after = [
          "network.target"
          "sound.target"
        ];
        wantedBy = [ "default.target" ];
        serviceConfig.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
      };
    };
  };

  documentation = {
    enable = true;
    info.enable = true;
    dev.enable = true;
    doc.enable = true;
    nixos.enable = true;
    man = {
      enable = true;
      generateCaches = true;
      man-db.enable = true;
    };
  };

  xdg = {
    autostart.enable = true;
    menus.enable = true;
    mime.enable = true;
    icons.enable = true;
  };

  system = {
    stateVersion = "25.05";
    userActivationScripts = {
      update-desktop-entries = "${pkgs.desktop-file-utils}/bin/update-desktop-database";
    };
  };
}
