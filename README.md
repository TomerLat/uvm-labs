# uvm-labs

SystemVerilog labs for Vivado xsim. Each lab is one directory and uses the
same layout. The git history stores the sources and the scripts. Vivado's
generated project, waveforms, and logs stay on this machine.

Vivado on this PC is 2020.2, which already ships UVM. The simulator is
switched on with `-L uvm`. You do not copy the UVM library into the repo.

## Layout

```
<lab>/rtl/                    design
<lab>/tb/                     testbench
<lab>/constraints/            empty until you pick pins
<lab>/scripts/run_sim.sh      batch simulation
<lab>/scripts/create_project.tcl
```

Add the next lab as a sibling of `multiplier/` with those same folders.

## Multiplier

```
multiplier/rtl/top.sv
multiplier/tb/tb.sv
multiplier/constraints/multiplier.xdc
multiplier/scripts/run_sim.sh
multiplier/scripts/create_project.tcl
```

The part is `xc7a200tfbg676-2` on the AC701 board.

```bash
./multiplier/scripts/run_sim.sh
```

To open it in Vivado:

```bash
source ~/Xilinx/Vivado/2020.2/settings64.sh
vivado -mode batch -source multiplier/scripts/create_project.tcl
vivado multiplier/vivado/multiplier.xpr
```

The project file points back at `multiplier/rtl/` and `multiplier/tb/`.
Edit those files, not a copy under `multiplier/vivado/`.

`multiplier/vivado/` is gitignored. After you clone the repo on another
machine, run `create_project.tcl` again.

## What git keeps

Commit `.sv`, `.xdc`, `.tcl`, and this README.

Do not commit `.cache`, `.sim`, `.runs`, `.hw`, `.ip_user_files`, `.jou`,
`.log`, `.wdb`, or the `.xpr`. Vivado rewrites those every run.
