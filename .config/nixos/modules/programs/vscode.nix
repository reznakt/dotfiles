{ config, pkgs, lib, ... }:

{
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;
    package = pkgs.vscode-fhs;
    profiles.default = {
      enableExtensionUpdateCheck = true;
      enableUpdateCheck = false;
      # prefer packages from nixpkgs when available, fallback to marketplace
      extensions = (
        with pkgs.vscode-marketplace;
        with pkgs.vscode-extensions;
        [
          lucasfa.octaveexecution
          aaron-bond.better-comments
          arrterian.nix-env-selector
          charliermarsh.ruff
          dbaeumer.vscode-eslint
          editorconfig.editorconfig
          esbenp.prettier-vscode
          github.copilot
          github.copilot-chat
          hashicorp.terraform
          jnoortheen.nix-ide
          k--kato.intellij-idea-keybindings
          kchusap.opl
          mechatroner.rainbow-csv
          ms-python.debugpy
          ms-python.python
          ms-python.vscode-pylance
          ms-toolsai.datawrangler
          ms-toolsai.jupyter
          ms-toolsai.jupyter-keymap
          ms-toolsai.jupyter-renderers
          ms-vscode-remote.remote-containers
          ms-vscode-remote.remote-ssh
          paulosilva.vsc-octave-debugger
          pflannery.vscode-versionlens
          sanaajani.taskrunnercode
          t3dotgg.vsc-material-theme-but-i-wont-sue-you
          toasty-technologies.octave
          tusindfryd.octave-formatter
          usernamehw.errorlens
          vscode-icons-team.vscode-icons
          yoavbls.pretty-ts-errors
        ]
      );
      userSettings = {
        "editor.cursorBlinking" = "smooth";
        "editor.fontFamily" = "JetBrains Mono";
        "editor.fontLigatures" = true;
        "editor.fontSize" = 13;
        "editor.linkedEditing" = true;
        "editor.smoothScrolling" = true;
        "explorer.sortOrder" = "type";
        "files.autoSave" = "afterDelay";
        "git.autofetch" = true;
        "github.copilot.chat.agent.autoFix" = true;
        "github.copilot.nextEditSuggestions.enabled" = true;
        "python.analysis.typeCheckingMode" = "strict";
        "python.languageServer" = "Pylance";
        "terminal.integrated.cursorBlinking" = true;
        "terminal.integrated.fontLigatures.enabled" = true;
        "terminal.integrated.smoothScrolling" = true;
        "terminal.integrated.stickyScroll.enabled" = false;
        "update.showReleaseNotes" = false;
        "vsicons.dontShowNewVersionMessage" = true;
        "workbench.colorTheme" = "Material Theme Darker";
        "workbench.iconTheme" = "vscode-icons";
        "workbench.list.smoothScrolling" = true;
        "workbench.startupEditor" = "none";
      };
    };
  };
}
