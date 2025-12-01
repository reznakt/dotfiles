{ config, pkgs, lib, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    autosuggestion = {
      enable = true;
      strategy = [
        "history"
        "completion"
      ];
    };

    initContent = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
    '';

    oh-my-zsh = {
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
      sops = "EDITOR=micro sops";
      strace = "lurk";
      nix-shell = "nix-shell --run $SHELL";
      nix-develop = "nix develop -c $SHELL";
    };

    history = {
      append = true;
      extended = true;
      ignoreAllDups = true;
      share = true;
    };
  };
}
