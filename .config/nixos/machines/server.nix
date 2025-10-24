{
  lib,
  config,
  pkgs,
  ...
}:

{
  networking.hostName = "server";

  hardware = {
    cpu.intel.updateMicrocode = true;
  };
}
