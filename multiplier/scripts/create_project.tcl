# Recreate the Vivado project from the sources in this lab.
# The project lands in vivado/, which git ignores.
#
#   source ~/Xilinx/Vivado/2020.2/settings64.sh
#   vivado -mode batch -source multiplier/scripts/create_project.tcl

set script_dir [file normalize [file dirname [info script]]]
set root [file normalize [file join $script_dir ..]]
set proj_dir [file join $root vivado]
set part xc7a200tfbg676-2

file mkdir $proj_dir
create_project multiplier $proj_dir -part $part -force
set_property board_part xilinx.com:ac701:part0:1.4 [current_project]

set rtl [file normalize [file join $root rtl top.sv]]
add_files -norecurse $rtl
set_property file_type SystemVerilog [get_files $rtl]
set_property top top [current_fileset]

set tb [file normalize [file join $root tb tb.sv]]
add_files -fileset sim_1 -norecurse $tb
set tb_obj [get_files $tb]
set_property file_type SystemVerilog $tb_obj
set_property used_in_synthesis false $tb_obj
set_property used_in_implementation false $tb_obj
set_property top tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]

set_property -name {xsim.compile.xvlog.more_options} -value {-L uvm} -objects [get_filesets sim_1]
set_property -name {xsim.elaborate.xelab.more_options} -value {-L uvm} -objects [get_filesets sim_1]
set_property -name {xsim.simulate.runtime} -value {1us} -objects [get_filesets sim_1]

set xdc [file normalize [file join $root constraints multiplier.xdc]]
add_files -fileset constrs_1 -norecurse $xdc

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "INFO: Project written to $proj_dir/multiplier.xpr"
