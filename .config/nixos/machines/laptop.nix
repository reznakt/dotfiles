{
  lib,
  config,
  pkgs,
  ...
}:

{
  networking.hostName = "laptop";

  boot.initrd.luks.devices."luks-1953300c-4e53-4b52-a258-34d0b2b175bb".device =
    "/dev/disk/by-uuid/1953300c-4e53-4b52-a258-34d0b2b175bb";

  nixpkgs.overlays = [
    (final: prev: {
      libfprint = prev.libfprint.overrideAttrs (old: {
        mesonFlags = old.mesonFlags ++ [ "-Ddrivers=elanmoc2" ];
        src = builtins.fetchGit {
          url = "https://gitlab.freedesktop.org/depau/libfprint.git";
          ref = "elanmoc2";
          rev = "f0b8bbc60e754d5b34aef3cb6b02d9eb275e5af6";
        };
      });
    })
  ];

  security.pam.services = {
    hyprlock.fprintAuth = true;
    login.fprintAuth = true;
    polkit-1.fprintAuth = true;
    su.fprintAuth = true;
    sudo.fprintAuth = true;
  };

  systemd.services.fprintd = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "simple";
  };

  services.fprintd.enable = true;
  programs.hyprlock.enable = true;
}
