{ config, pkgs, lib, ... }:

{
  programs.librewolf = {
    enable = true;
    settings = {
      "accessibility.force_disabled" = 1;
      "browser.aboutConfig.showWarning" = false;
      "browser.cache.disk.enable" = false;
      "browser.cache.memory.enable" = true;
      "browser.sessionstore.resume_from_crash" = false;
      "browser.theme.content-theme" = 0;
      "browser.translations.enable" = false;
      "browser.urlbar.trimHttps" = false;
      "browser.urlbar.trimURLs" = false;
      "browser.vpn_promo.enabled" = false;
      "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
      "extensions.pocket.enabled" = false;
      "extensions.update.autoUpdateDefault" = true;
      "extensions.update.enabled" = true;
      "findbar.highlightAll" = true;
      "font.name.monospace.x-western" = "UbuntuMono Nerd Font Mono";
      "font.name.sans-serif.x-western" = "UbuntuSans Nerd Font";
      "font.name.serif.x-western" = "Ubuntu Nerd Font";
      "full-screen-api.warning.timeout" = 0;
      "general.autoScroll" = true;
      "general.smoothScroll" = true;
      "identity.fxaccounts.enabled" = true;
      "pdfjs.viewerCssTheme" = 2;
      "privacy.donottrackheader.enabled" = true;
      "privacy.fingerprintingProtection" = true;
      "privacy.fingerprintingProtection.overrides" = "+AllTargets,-CSSPrefersColorScheme";
      "privacy.fingerprintingProtection.pbmode" = true;
      "privacy.resistFingerprinting" = false;
      "privacy.resistFingerprinting.pbmode" = false;
      "security.OCSP.enable" = true;
      "webgl.disabled" = true;
    };
  };

  programs.chromium = {
    enable = true;
    package = pkgs.ungoogled-chromium;
  };
}
