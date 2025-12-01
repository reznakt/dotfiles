{ config, pkgs, lib, ... }:

{
  programs.mpv = {
    enable = true;
    scripts = with pkgs.mpvScripts; [ mpris ];
  };

  programs.freetube = {
    enable = true;
    settings = {
      "app.closeToTray" = true;
      "app.minimizeToTray" = true;
      "app.startupBehavior" = "continue-where-left-off";
      "app.theme" = "dark";
      "backendFallback" = false;
      "backendPreference" = "local";
      "baseTheme" = "catppuccinMocha";
      "checkForBlogPosts" = false;
      "checkForUpdates" = false;
      "defaultQuality" = "2160";
      "externalLinkHandling" = "openLinkAfterPrompt";
      "generalAutoLoadMorePaginatedItemsEnabled" = true;
      "hideHeaderLogo" = true;
      "mainColor" = "Blue";
      "player.defaultQuality" = "high";
      "player.hardwareAcceleration" = true;
      "region" = "CZ";
      "useDeArrowThumbnails" = true;
      "useDeArrowTitles" = true;
      "useRssFeeds" = true;
      "useSponsorBlock" = true;
      "videoVolumeMouseScroll" = false;
    };
  };

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    plugins = with pkgs.yaziPlugins; {
      rsync = rsync;
      chmod = chmod;
      git = git;
      sudo = sudo;
      ouch = ouch;
      glow = glow;
      diff = diff;
      duckdb = duckdb;
      bypass = bypass;
      mediainfo = mediainfo;
      full-border = full-border;
      rich-preview = rich-preview;
    };
  };
}
