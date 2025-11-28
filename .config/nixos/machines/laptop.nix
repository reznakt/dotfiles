{
  lib,
  config,
  pkgs,
  ...
}:

let
  pamServicesWithFprint = [
    "hyprlock"
    "login"
    "polkit-1"
    "su"
    "sudo"
  ];

  fprintdConfig = name: {
    rules.auth.fprintd.settings = {
      timeout = -1;
      max-tries = -1;
    };
  };
in
{
  networking.hostName = "laptop";

  boot = {
    initrd = {
      luks.devices."luks-1953300c-4e53-4b52-a258-34d0b2b175bb".device =
        "/dev/disk/by-uuid/1953300c-4e53-4b52-a258-34d0b2b175bb";
      availableKernelModules = [ "amdgpu" ];
    };

    loader = {
      timeout = lib.mkForce (-1);
      grub.default = 1;
    };
  };

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

  security.pam.services = lib.mapAttrs' (name: _: lib.nameValuePair name (fprintdConfig name)) (
    lib.genAttrs pamServicesWithFprint (name: { })
  );

  systemd.services.fprintd = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "simple";
  };

  programs.hyprlock.enable = true;

  services = {
    fprintd.enable = true;
    printing = {
      enable = true;

      drivers = with pkgs; [
        foo2zjs
        foomatic-db
        foomatic-db-engine
        foomatic-db-ppds
        foomatic-filters
      ];
    };
  };

  hardware = {
    printers = {
      ensureDefaultPrinter = "Epson_AL-C1600";

      ensurePrinters = [
        {
          name = "Epson_AL-C1600";
          deviceUri = "usb://EPSON/AL-C1600?serial=08571";
          model = "KONICA_MINOLTA-magicolor_1600W.ppd.gz";
          ppdOptions = {
            PageSize = "A4";
            ColorMode = "ICM";
            Resolution = "1200x600dpi";
          };
        }
      ];
    };

    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General.Experimental = true;
    };

    cpu.amd.updateMicrocode = true;
    amdgpu.initrd.enable = true;
  };
}
