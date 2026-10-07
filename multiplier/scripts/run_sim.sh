#!/usr/bin/env bash
# Compile and run this lab with Vivado xsim.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

if ! command -v xvlog >/dev/null 2>&1; then
  settings="$HOME/Xilinx/Vivado/2020.2/settings64.sh"
  if [[ ! -f "$settings" ]]; then
    echo "xvlog is not on PATH, and $settings was not found." >&2
    echo "Source your Vivado settings64.sh, then run this script again." >&2
    exit 1
  fi
  # Vivado's settings script reads variables it does not define.
  set +u
  # shellcheck disable=SC1090
  source "$settings"
  set -u
fi

rm -rf xsim.dir .Xil
rm -f xvlog.log xvlog.pb xelab.log xelab.pb xsim.log xsim.jou

xvlog -sv -L uvm -f "$root/scripts/filelist.f"
xelab -L uvm tb -s sim_snapshot --timescale 1ns/1ps
xsim sim_snapshot -R
