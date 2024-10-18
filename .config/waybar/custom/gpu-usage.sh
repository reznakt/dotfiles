#!/bin/sh

AMD_GPU_FILE="/sys/class/drm/card0/device/gpu_busy_percent"

if [ -f "$AMD_GPU_FILE" ]; then # AMD
  cat "$AMD_GPU_FILE"
elif command -v nvidia-smi > /dev/null 2>&1; then # Nvidia
  nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits
fi

