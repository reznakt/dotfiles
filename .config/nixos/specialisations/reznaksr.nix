{
  lib,
  config,
  pkgs,
  reznaksr,
  isSpecialisation,
  ...
}:
let
  homeManagerModule = reznaksr;
  username = "reznaksr";
in
{
  system.nixos.tags = [ username ];
  home-manager.users.${username} = homeManagerModule;

  users.users = {
    ${username} = {
      isNormalUser = true;
      description = "Tomáš Režňák, Sr.";
      hashedPasswordFile = config.sops.secrets."password-hash-${username}".path;
      extraGroups = [
        "audio"
        "docker"
        "networkmanager"
        "video"
      ];
    };
  };

  environment = {
    etc.specialisation = lib.mkIf (isSpecialisation) {
      text = username;
      mode = "0644";
    };

    systemPackages = with pkgs.gnomeExtensions; [
      appindicator
      blur-my-shell
      dash-to-dock
    ];
  };

  programs = {
    dconf.enable = true;
  };

  services = {
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;

    gnome = {
      gnome-keyring.enable = true;
      gnome-online-accounts.enable = true;
      sushi.enable = true;
    };

    xserver.xkb = {
      layout = "us";
      variant = "";
    };
  };

  security.pam.services = {
    gdm-password.enableGnomeKeyring = true;
    gdm.enableGnomeKeyring = true;
    login.enableGnomeKeyring = true;
  };
}
