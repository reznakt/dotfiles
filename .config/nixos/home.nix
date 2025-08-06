{ config, pkgs, ... }:

{
  home = {
    username = "reznak";
    homeDirectory = "/home/reznak";
    stateVersion = "25.05";

    packages = with pkgs; [
      firefox
      ripgrep
      fd
      bat
    ];
  };
}
