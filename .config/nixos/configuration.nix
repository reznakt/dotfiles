{
  lib,
  config,
  pkgs,
  ...
}:

{
  imports = [ ./hardware-configuration.nix ];

  boot = {
    kernelPackages = pkgs.linuxPackages;
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
        extraBin = {
          setleds = "${pkgs.kbd}/bin/setleds";
        };

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

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
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

  services.xserver.xkb = {
    layout = "cz";
    variant = "";
  };

  console.useXkbConfig = true;

  users.users.reznak = {
    isNormalUser = true;
    description = "Tomáš Režňák";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "audio"
      "docker"
      "gamemode"
    ];
    shell = pkgs.zsh;
  };

  nixpkgs = {
    config.allowUnfree = true;

    overlays = [
      (self: super: {
        mpv = super.mpv.override {
          scripts = [ self.mpvScripts.mpris ];
        };
      })
    ];
  };

  environment.systemPackages = with pkgs; [
    curl
    gcc
    kbd
    libnotify
    man-pages
    man-pages-posix
    mpv # TODO: move to user packages
    psmisc
    python313
    unzip
    wget
  ];

  programs.waybar.enable = true;
  programs.gamescope.enable = true;
  programs.nix-ld.enable = true;

  programs.nh = {
    enable = true;
    flake = "/etc/nixos/";
  };

  programs.gamemode = {
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

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.firefox = {
    enable = true;
    wrapperConfig = {
      pipewireSupport = true;
    };
    preferences = {
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
      "general.autoScroll" = true;
      "general.smoothScroll" = true;
    };
    autoConfig = ''
      pref("findbar.highlightAll", true);
      pref("font.name.monospace.x-western", "UbuntuMono Nerd Font Mono");
      pref("font.name.sans-serif.x-western", "UbuntuSans Nerd Font");
      pref("font.name.serif.x-western", "Ubuntu Nerd Font");
      pref("full-screen-api.warning.timeout", 0);
    '';
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  programs.zsh = {
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
        "git"
        "git-auto-fetch"
        "history"
        "npm"
        "pip"
        "poetry"
        "poetry-env"
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

  virtualisation.docker.enable = true;

  services.fstrim.enable = true;
  services.fwupd.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.openssh.enable = true;
  services.playerctld.enable = true;
  services.preload.enable = true;
  services.systembus-notify.enable = true;
  services.tlp.enable = true;

  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "uwsm start hyprland-uwsm.desktop";
        user = "reznak";
      };
      default_session = initial_session;
    };
  };

  services.kmscon = {
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

  services.earlyoom = {
    enable = true;
    enableNotifications = true;
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    audio.enable = true;
    wireplumber.enable = true;
    jack.enable = true;
  };

  security = {
    rtkit.enable = true;
    polkit.enable = true;
    pam.services.greetd.enableGnomeKeyring = true;
    pam.services.hyprlock.enableGnomeKeyring = true;
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

    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 30d";
    };

    distributedBuilds = false;

    buildMachines = [
      {
        hostName = "nixremote";
        system = "x86_64-linux";
        protocol = "ssh-ng";
        maxJobs = 1;
        speedFactor = 1;
        supportedFeatures = [
          "nixos-test"
          "benchmark"
          "big-parallel"
          "kvm"
        ];
        mandatoryFeatures = [ ];
      }
    ];
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

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General.Experimental = true;
    };

    graphics = {
      enable = true;
      enable32Bit = true;
    };

    cpu.amd.updateMicrocode = true;
    amdgpu.initrd.enable = true;
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
