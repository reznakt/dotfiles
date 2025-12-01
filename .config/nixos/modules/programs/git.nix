{ config, pkgs, lib, ... }:

{
  programs.git = {
    enable = true;
    lfs.enable = true;

    signing = {
      signByDefault = true;
      format = "ssh";
      key = "~/.ssh/id_ed25519.pub";
    };

    settings = {
      user = {
        name = "Tomáš Režňák";
        email = "tomas.reznak@volny.cz";
      };

      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };
}
