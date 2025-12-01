{ config, pkgs, lib, ... }:

{
  programs.ghostty = {
    enable = true;

    enableBashIntegration = false;
    enableZshIntegration = true;
    installBatSyntax = true;
    installVimSyntax = true;

    settings = {
      background-opacity = 0.5;
      background = "#202020";
      bold-is-bright = false;
      confirm-close-surface = false;

      cursor-opacity = 0.75;
      cursor-style-blink = true;
      cursor-style = "underline";

      font-family = "JetBrains Mono";
      font-size = 10;

      resize-overlay = "never";
      scrollback-limit = 10 * 1000 * 1000;
      shell-integration-features = "no-cursor";

      window-decoration = false;
      window-padding-x = 5;
      window-padding-y = 3;
    };
  };
}
