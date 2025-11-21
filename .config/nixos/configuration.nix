{
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [ ./hardware-configuration.nix ];

  sops = {
    defaultSopsFile = ./secrets.yaml;

    age = {
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };

    secrets = {
      password-hash-reznak.neededForUsers = true;
      password-hash-reznaksr.neededForUsers = true;
    };
  };

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
    networkmanager = {
      enable = true;
      plugins = with pkgs; [ networkmanager-openvpn ];
    };
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

  console = {
    earlySetup = true;
    useXkbConfig = true;
  };

  users = {
    mutableUsers = false;
    allowNoPasswordLogin = true;
  };

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [ kbd ];

  programs = {
    nix-ld.enable = true;
  };

  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  services = {
    fstrim.enable = true;
    fwupd.enable = true;
    openssh.enable = true;
    playerctld.enable = true;
    preload.enable = true;

    earlyoom = {
      enable = true;
      enableNotifications = true;
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
  };

  security = {
    rtkit.enable = true;
    polkit.enable = true;
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
        noto-fonts-color-emoji
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

    settings.Manager = {
      DefaultTimeoutStopSec = "15s";
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

  system.stateVersion = "25.05";
}
