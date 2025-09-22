{
  lib,
  config,
  pkgs,
  ...
}:

{
  networking.hostName = "desktop";

  boot = {
    initrd.luks.devices."luks-8ab404cd-daef-44f7-aeb7-608652583c50".device =
      "/dev/disk/by-uuid/8ab404cd-daef-44f7-aeb7-608652583c50";

    kernel.sysctl = {
      "vm.swappiness" = 0;
    };
  };

  security.sudo.wheelNeedsPassword = false;
}
