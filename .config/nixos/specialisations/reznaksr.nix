{
  lib,
  config,
  pkgs,
  reznaksr,
  isSpecialisation ? false,
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
  };
}
