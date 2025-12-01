# Programs module - imports all program-specific configurations
{ config, pkgs, lib, ... }:

{
  imports = [
    ./browsers.nix
    ./ghostty.nix
    ./git.nix
    ./hyprland.nix
    ./hyprlock.nix
    ./hyprpanel.nix
    ./media.nix
    ./neovim.nix
    ./utilities.nix
    ./vscode.nix
    ./zsh.nix
  ];
}
