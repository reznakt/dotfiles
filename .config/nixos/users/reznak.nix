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
  imports = [
    ../modules/programs
    ../modules/services
  ];

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
