{ config, pkgs, lib, ... }:

{
  programs.btop = {
    enable = true;

    settings = {
      color_theme = "Default";
      theme_background = false;
      truecolor = true;
      force_tty = false;

      presets =
        "cpu:1:default,proc:0:default "
        + "cpu:0:default,mem:0:default,net:0:default "
        + "cpu:0:block,net:0:tty";

      vim_keys = false;
      rounded_corners = true;

      graph_symbol = "braille";
      graph_symbol_cpu = "default";
      graph_symbol_gpu = "default";
      graph_symbol_mem = "default";
      graph_symbol_net = "default";
      graph_symbol_proc = "default";

      shown_boxes = "cpu mem net proc";
      update_ms = 500;

      proc_sorting = "cpu lazy";
      proc_reversed = false;
      proc_tree = true;
      proc_colors = true;
      proc_gradient = true;
      proc_per_core = true;
      proc_mem_bytes = true;
      proc_cpu_graphs = true;
      proc_info_smaps = false;
      proc_left = false;
      proc_filter_kernel = true;
      proc_aggregate = true;

      cpu_graph_upper = "total";
      cpu_graph_lower = "total";
      show_gpu_info = "Auto";
      cpu_invert_lower = true;
      cpu_single_graph = false;
      cpu_bottom = false;
      show_uptime = true;
      show_cpu_watts = true;
      check_temp = true;
      cpu_sensor = "Auto";
      show_coretemp = true;
      cpu_core_map = "";
      temp_scale = "celsius";

      base_10_sizes = false;
      show_cpu_freq = true;

      clock_format = " %X";
      background_update = true;
      custom_cpu_name = "";

      disks_filter = "";
      mem_graphs = true;
      mem_below_net = false;
      zfs_arc_cached = true;
      show_swap = true;
      swap_disk = true;
      show_disks = true;
      only_physical = true;
      use_fstab = false;
      zfs_hide_datasets = false;
      disk_free_priv = false;
      show_io_stat = true;
      io_mode = false;
      io_graph_combined = false;
      io_graph_speeds = "";

      net_download = 100;
      net_upload = 20;
      net_auto = false;
      net_sync = false;
      net_iface = "";
      base_10_bitrate = "Auto";

      show_battery = true;
      selected_battery = "Auto";
      show_battery_watts = true;

      log_level = "ERROR";

      nvml_measure_pcie_speeds = true;
      rsmi_measure_pcie_speeds = true;
      gpu_mirror_graph = true;
    };
  };

  programs.lsd = {
    enable = true;

    enableBashIntegration = true;
    enableZshIntegration = true;

    settings = {
      classic = false;
      date = "date";
      dereference = false;
      header = false;
      hyperlink = "never";
      indicators = true;
      layout = "grid";
      literal = false;
      no-symlink = false;
      permission = "rwx";
      recursion.enabled = false;
      size = "default";
      symlink-arrow = "->";
      total-size = false;

      blocks = [
        "permission"
        "user"
        "size"
        "date"
        "name"
      ];

      color = {
        when = "auto";
        theme = "default";
      };

      icons = {
        when = "auto";
        theme = "fancy";
        separator = " ";
      };

      sorting = {
        column = "name";
        reverse = false;
        dir-grouping = "first";
      };

      truncate-owner = {
        after = 15;
        marker = "...";
      };
    };
  };

  programs.tmux = {
    enable = true;
    clock24 = true;
    keyMode = "vi";
    mouse = true;
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "*" = {
        forwardAgent = false;
        addKeysToAgent = "no";
        compression = false;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
      };

      server = {
        hostname = "192.168.0.250";
      };

      aisa = {
        hostname = "aisa.fi.muni.cz";
        user = "xreznak";
      };

      anxur = {
        hostname = "anxur.fi.muni.cz";
        user = "xreznak";
      };

      apollo = {
        proxyJump = "aisa";
        user = "xreznak";
      };

      aura = {
        proxyJump = "aisa";
        user = "xreznak";
      };
    };
  };

  programs.fastfetch.enable = true;
  programs.go.enable = true;
  programs.micro.enable = true;

  programs.onlyoffice = {
    enable = true;
    settings = {
      UITheme = "theme-night";
    };
  };

  programs.thunderbird = {
    enable = true;
    profiles.default = {
      isDefault = true;
    };
  };
}
