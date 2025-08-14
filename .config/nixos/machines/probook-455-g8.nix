{
  lib,
  config,
  pkgs,
  ...
}:

{
  networking.hostName = "probook-455-g8";
  boot.initrd.luks.devices."luks-1953300c-4e53-4b52-a258-34d0b2b175bb".device = "/dev/disk/by-uuid/1953300c-4e53-4b52-a258-34d0b2b175bb";

  virtualisation = {
    virtualbox = {
      host = {
        enable = true;
        enableExtensionPack = true;
      };
    };
  };
}
